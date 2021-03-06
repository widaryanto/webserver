#!/bin/bash
clear
# Checking permissions
if [[ $EUID -ne 0 ]]; then
   ee_lib_echo_fail "Sudo privilege required..."
   exit 100
fi

# Define echo function
# Blue color
function ee_lib_echo()
{
   echo $(tput setaf 4)$@$(tput sgr0)
}
# White color
function ee_lib_echo_info()
{
   echo $(tput setaf 7)$@$(tput sgr0)
}
# Red color
function ee_lib_echo_fail()
{
   echo $(tput setaf 1)$@$(tput sgr0)
}

# Execute: update
ee_lib_echo "Updating, please wait..."
yum -y update
clear
yum groupinstall "Development Tools" -y

# Execute: installing
ee_lib_echo "Installing webserver, please wait..."
yum -y install httpd 
yum -y install composer
service httpd start
/sbin/iptables -I INPUT -p tcp --dport 80 -j ACCEPT
/etc/rc.d/init.d/iptables save

ee_lib_echo "Installing php 7.3, please wait..."
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm

yum -y install yum-utils wget
yum-config-manager --enable remi-php73
yum -y install php php-common php-xml php-mbstring unzip curl wget htop git php-mcrypt php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo

chkconfig httpd on
rm -f /etc/httpd/conf/httpd.conf
curl -o  /etc/httpd/conf/httpd.conf https://raw.githubusercontent.com/mozvid/webserver/master/httpd.conf

# Php version
echo -n "[In progress] Detect PHP version ..."
VER_PHP="$(command php --version 2>'/dev/null' \
   | command head -n 1 \
   | command cut --characters=5-7)"
sleep 3s
echo -e "\r\e[0;32m[OK]\e[0m Detect PHP version  : $VER_PHP   "

# Execute: installing ioncube
#ee_lib_echo "Installing ioncube, please wait..."
#cd /var/www/html
#wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
#tar xvfz ioncube*
#cp /var/www/html/ioncube/ioncube_loader_lin_${VER_PHP}.so /usr/lib64/php/modules
#echo "zend_extension = /usr/lib64/php/modules/ioncube_loader_lin_${VER_PHP}.so" >> /etc/php.d/00-ioncube.ini

service httpd restart
#rm -rf /var/www/html/ioncube*
clear
ee_lib_echo "Cek Spesifikasi PHP:"
php -v
httpd -v
curl -o  /var/www/html/bench.php https://raw.githubusercontent.com/mozvid/webserver/master/bench.php
php bench.php

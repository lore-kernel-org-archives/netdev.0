From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] remove historic entries in Documentation/Changes
Date: Wed, 29 Oct 2003 01:22:02 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031029.012202.105420248.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

It seems that these entries are out-of-date;
"bk annotate" tells these lines are very old.

Please ensure if it is correct.

===== Documentation/Changes 1.44 vs edited =====
--- 1.44/Documentation/Changes	Sun Oct  5 15:50:47 2003
+++ edited/Documentation/Changes	Wed Oct 29 01:00:17 2003
@@ -59,8 +59,6 @@
 o  xfsprogs               2.1.0                   # xfs_db -V
 o  pcmcia-cs              3.1.21                  # cardmgr -V
 o  quota-tools            3.09                    # quota -V
-o  PPP                    2.4.0                   # pppd --version
-o  isdn4k-utils           3.1pre1                 # isdnctrl 2>&1|grep version
 o  nfs-utils              1.0.5                   # showmount --version
 o  procps                 3.1.13                  # ps --version
 o  oprofile               0.5.3                   # oprofiled --version
@@ -234,52 +232,6 @@
 Networking
 ==========
 
-General changes
----------------
-
-The IP firewalling and NAT code has been replaced again.  The new
-netfilter software (including ipfwadm and ipchains backwards-
-compatible modules) is currently distributed separately.
-
-If you have advanced network configuration needs, you should probably
-consider using the network tools from ip-route2.
-
-PPP
----
-
-The PPP driver has been restructured to support multilink and to
-enable it to operate over diverse media layers.  If you use PPP,
-upgrade pppd to at least 2.4.0.
-
-If you are not using devfs, you must have the device file /dev/ppp
-which can be made by:
-
-mknod /dev/ppp c 108 0
-
-as root.
-
-If you build ppp support as modules, you will need the following in
-your /etc/modules.conf file:
-
-alias char-major-108	ppp_generic
-alias /dev/ppp		ppp_generic
-alias tty-ldisc-3	ppp_async
-alias tty-ldisc-14	ppp_synctty
-alias ppp-compress-21	bsd_comp
-alias ppp-compress-24	ppp_deflate
-alias ppp-compress-26	ppp_deflate
-
-If you use devfsd and build ppp support as modules, you will need
-the following in your /etc/devfsd.conf file:
-
-LOOKUP	PPP	MODLOAD
-
-Isdn4k-utils
-------------
-
-Due to changes in the length of the phone number field, isdn4k-utils
-needs to be recompiled or (preferably) upgraded.
-
 NFS-utils
 ---------
 
@@ -385,34 +337,12 @@
 ----------
 o  <http://powertweak.sourceforge.net/>
 
-Networking
-**********
-
-PPP
----
-o  <ftp://ftp.samba.org/pub/ppp/ppp-2.4.0.tar.gz>
-
-Isdn4k-utils
-------------
-o  <ftp://ftp.isdn4linux.de/pub/isdn4linux/utils/isdn4k-utils.v3.1pre1.tar.gz>
-
-NFS-utils
----------
-o  <http://sourceforge.net/project/showfiles.php?group_id=14>
-
-Netfilter
----------
-o  <http://netfilter.filewatcher.org/iptables-1.2.tar.bz2>
-o  <http://netfilter.samba.org/iptables-1.2.tar.bz2>
-o  <http://netfilter.kernelnotes.org/iptables-1.2.tar.bz2>
-
-Ip-route2
----------
-o  <ftp://ftp.inr.ac.ru/ip-routing/iproute2-2.2.4-now-ss991023.tar.gz>
-
 OProfile
 --------
 o  <http://oprofile.sf.net/download/>
+
+Networking
+**********
 
 NFS-Utils
 ---------


-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

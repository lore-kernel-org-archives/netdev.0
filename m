From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] net Kconfig consolidation
Date: Thu, 25 Sep 2003 13:57:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925115717.GA32636@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

include net/ax25/Kconfig, net/irda/Kconfig and net/bluetooth/Kconfig
from net/Kconfig like all the other Kconfig files under net/.  This
makes the per-arch Kconfig files quite a bit smaller and also makes
sure the option are available on all arches.


--- 1.28/arch/alpha/Kconfig	Tue Sep  9 23:16:03 2003
+++ edited/arch/alpha/Kconfig	Tue Sep 23 22:08:47 2003
@@ -654,8 +654,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/cdrom/Kconfig"
@@ -674,8 +672,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 source "arch/alpha/oprofile/Kconfig"
 
===== arch/arm/Kconfig 1.35 vs edited =====
--- 1.35/arch/arm/Kconfig	Wed Sep 17 00:11:53 2003
+++ edited/arch/arm/Kconfig	Tue Sep 23 22:05:51 2003
@@ -629,11 +629,6 @@
 
 source "net/Kconfig"
 
-#   source net/ax25/Config.in
-source "net/irda/Kconfig"
-
-source "net/ax25/Kconfig"
-
 source "drivers/ide/Kconfig"
 
 source "drivers/scsi/Kconfig"
--- 1.8/arch/arm26/Kconfig	Wed Aug 27 02:27:45 2003
+++ edited/arch/arm26/Kconfig	Tue Sep 23 22:06:00 2003
@@ -203,8 +203,6 @@
 
 source "net/Kconfig"
 
-source "net/irda/Kconfig"
-
 source "drivers/ide/Kconfig"
 
 source "drivers/scsi/Kconfig"
@@ -238,9 +236,6 @@
 source "drivers/misc/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
-
 
 menu "Kernel hacking"
 
--- 1.14/arch/cris/Kconfig	Sat Aug  2 23:26:16 2003
+++ edited/arch/cris/Kconfig	Tue Sep 23 22:06:06 2003
@@ -178,10 +178,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/telephony/Kconfig"
--- 1.8/arch/h8300/Kconfig	Mon Sep  1 01:14:22 2003
+++ edited/arch/h8300/Kconfig	Tue Sep 23 22:06:12 2003
@@ -191,10 +191,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/telephony/Kconfig"
@@ -351,8 +347,6 @@
 source "fs/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 
 menu "Kernel hacking"
--- 1.76/arch/i386/Kconfig	Wed Sep 10 08:41:39 2003
+++ edited/arch/i386/Kconfig	Tue Sep 23 22:06:20 2003
@@ -1201,10 +1201,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/telephony/Kconfig"
@@ -1226,8 +1222,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 source "arch/i386/oprofile/Kconfig"
 
--- 1.44/arch/ia64/Kconfig	Tue Sep 16 00:22:39 2003
+++ edited/arch/ia64/Kconfig	Tue Sep 23 22:06:35 2003
@@ -527,8 +527,6 @@
 
 if !IA64_HP_SIM
 
-source "net/ax25/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/cdrom/Kconfig"
@@ -575,9 +573,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-
-source "net/bluetooth/Kconfig"
 
 endif
 
--- 1.21/arch/m68knommu/Kconfig	Mon Sep  1 01:14:22 2003
+++ edited/arch/m68knommu/Kconfig	Tue Sep 23 22:06:54 2003
@@ -530,10 +530,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/telephony/Kconfig"
@@ -555,8 +551,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 
 menu "Kernel hacking"
--- 1.17/arch/mips/Kconfig	Mon Sep  8 03:44:39 2003
+++ edited/arch/mips/Kconfig	Tue Sep 23 22:07:01 2003
@@ -1228,10 +1228,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/telephony/Kconfig"
@@ -1289,8 +1285,6 @@
 endmenu
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 
 menu "Kernel hacking"
--- 1.23/arch/parisc/Kconfig	Tue Sep  9 00:00:21 2003
+++ edited/arch/parisc/Kconfig	Tue Sep 23 22:07:13 2003
@@ -190,12 +190,6 @@
 
 #source drivers/message/i2o/Kconfig
 
-source "net/Kconfig"
-
-#source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 #source "drivers/isdn/Kconfig"
 
 #source "drivers/telephony/Kconfig"
@@ -216,8 +210,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 source "arch/parisc/oprofile/Kconfig"
 
--- 1.42/arch/ppc/Kconfig	Wed Sep 17 22:31:25 2003
+++ edited/arch/ppc/Kconfig	Tue Sep 23 22:07:17 2003
@@ -1142,10 +1142,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/video/Kconfig"
@@ -1322,8 +1318,6 @@
 endmenu
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 source "lib/Kconfig"
 
--- 1.29/arch/ppc64/Kconfig	Tue Sep  9 21:51:58 2003
+++ edited/arch/ppc64/Kconfig	Tue Sep 23 22:07:29 2003
@@ -263,10 +263,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/telephony/Kconfig"
@@ -287,8 +283,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 
 menu "iSeries device drivers"
===== arch/sh/Kconfig 1.18 vs edited =====
--- 1.18/arch/sh/Kconfig	Mon Sep  1 01:14:22 2003
+++ edited/arch/sh/Kconfig	Tue Sep 23 22:07:41 2003
@@ -753,10 +753,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/telephony/Kconfig"
@@ -1148,8 +1144,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 
 menu "Kernel hacking"
===== arch/sparc/Kconfig 1.20 vs edited =====
--- 1.20/arch/sparc/Kconfig	Mon Sep  1 01:14:22 2003
+++ edited/arch/sparc/Kconfig	Tue Sep 23 22:08:03 2003
@@ -464,8 +464,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
 # This one must be before the filesystem configs. -DaveM
 
 menu "Unix98 PTY support"
@@ -521,9 +519,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
-
 
 menu "Watchdog"
 
--- 1.33/arch/sparc64/Kconfig	Fri Sep 12 03:13:31 2003
+++ edited/arch/sparc64/Kconfig	Tue Sep 23 22:08:18 2003
@@ -666,10 +666,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 source "drivers/telephony/Kconfig"
@@ -772,8 +768,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 
 menu "Watchdog"
===== arch/v850/Kconfig 1.18 vs edited =====
--- 1.18/arch/v850/Kconfig	Mon Sep  1 01:14:22 2003
+++ edited/arch/v850/Kconfig	Tue Sep 23 22:08:29 2003
@@ -301,10 +301,6 @@
 
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 #source "drivers/telephony/Kconfig"
@@ -326,8 +322,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 
 menu "Kernel hacking"
===== arch/x86_64/Kconfig 1.30 vs edited =====
--- 1.30/arch/x86_64/Kconfig	Mon Sep  8 03:44:40 2003
+++ edited/arch/x86_64/Kconfig	Tue Sep 23 22:08:43 2003
@@ -419,10 +419,6 @@
 #source drivers/message/i2o/Config.in
 source "net/Kconfig"
 
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
 source "drivers/isdn/Kconfig"
 
 # no support for non IDE/SCSI cdroms as they were all ISA only
@@ -444,8 +440,6 @@
 source "sound/Kconfig"
 
 source "drivers/usb/Kconfig"
-
-source "net/bluetooth/Kconfig"
 
 source "arch/x86_64/oprofile/Kconfig"
 
--- 1.23/net/Kconfig	Sat Sep 20 03:59:21 2003
+++ edited/net/Kconfig	Tue Sep 23 22:05:26 2003
@@ -689,4 +689,10 @@
 
 source "drivers/net/Kconfig"
 
+source "net/ax25/Kconfig"
+
+source "net/irda/Kconfig"
+
+source "net/bluetooth/Kconfig"
+
 endmenu

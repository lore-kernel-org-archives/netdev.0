From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] janitor: remove (or add) unneeded includes (wireless)
Date: Wed, 17 Sep 2003 15:17:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030917151738.76585759.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply to 2.6.0-test5-current.

Thanks,
--
~Randy


From: Randy Hron <rwhron@earthlink.net>

 linux-260-test5-kj-rddunlap/drivers/net/wireless/airo.c       |    2 --
 linux-260-test5-kj-rddunlap/drivers/net/wireless/arlan-proc.c |    3 ---
 linux-260-test5-kj-rddunlap/drivers/net/wireless/arlan.c      |    1 +
 linux-260-test5-kj-rddunlap/drivers/net/wireless/arlan.h      |    1 -
 linux-260-test5-kj-rddunlap/drivers/net/wireless/strip.c      |    1 -
 5 files changed, 1 insertion(+), 7 deletions(-)

diff -puN drivers/net/wireless/airo.c~version_wireless drivers/net/wireless/airo.c
--- linux-260-test5-kj/drivers/net/wireless/airo.c~version_wireless	2003-09-10 17:09:51.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wireless/airo.c	2003-09-10 17:09:51.000000000 -0700
@@ -18,7 +18,6 @@
 ======================================================================*/
 
 #include <linux/config.h>
-#include <linux/version.h>
 #include <linux/init.h>
 
 #include <linux/kernel.h>
@@ -42,7 +41,6 @@
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
 #include <linux/ioport.h>
-#include <linux/config.h>
 #include <linux/pci.h>
 #include <asm/uaccess.h>
 
diff -puN drivers/net/wireless/arlan.c~version_wireless drivers/net/wireless/arlan.c
--- linux-260-test5-kj/drivers/net/wireless/arlan.c~version_wireless	2003-09-10 17:09:51.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wireless/arlan.c	2003-09-10 17:09:51.000000000 -0700
@@ -5,6 +5,7 @@
  * This module provides support for the Arlan 655 card made by Aironet
  */
 
+#include <linux/version.h>
 #include <linux/config.h>
 #include "arlan.h"
 
diff -puN drivers/net/wireless/arlan.h~version_wireless drivers/net/wireless/arlan.h
--- linux-260-test5-kj/drivers/net/wireless/arlan.h~version_wireless	2003-09-10 17:09:51.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wireless/arlan.h	2003-09-10 17:09:51.000000000 -0700
@@ -3,7 +3,6 @@
  *  Copyright (C) 1998 Elmer.Joandi@ut.ee, +37-255-13500	
  *  GNU General Public License applies
  */
-#include <linux/version.h>
 
 #include <linux/module.h>
 #include <linux/config.h>
diff -puN drivers/net/wireless/arlan-proc.c~version_wireless drivers/net/wireless/arlan-proc.c
--- linux-260-test5-kj/drivers/net/wireless/arlan-proc.c~version_wireless	2003-09-10 17:09:51.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wireless/arlan-proc.c	2003-09-10 17:09:51.000000000 -0700
@@ -5,9 +5,6 @@
 
 #ifdef CONFIG_PROC_FS
 
-
-#include <linux/version.h>
-
 /* void enableReceive(struct net_device* dev);
 */
 
diff -puN drivers/net/wireless/strip.c~version_wireless drivers/net/wireless/strip.c
--- linux-260-test5-kj/drivers/net/wireless/strip.c~version_wireless	2003-09-10 17:09:51.000000000 -0700
+++ linux-260-test5-kj-rddunlap/drivers/net/wireless/strip.c	2003-09-10 17:09:51.000000000 -0700
@@ -83,7 +83,6 @@ static const char StripVersion[] = "1.3A
 
 #include <linux/config.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/init.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>

_

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 1/2] typhoon: use module_param
Date: Fri, 15 Oct 2004 13:53:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015135353.53b1f263@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	2004-10-15 12:27:28 -07:00
+++ b/drivers/net/via-rhine.c	2004-10-15 12:27:28 -07:00
@@ -177,6 +177,7 @@
 #define PKT_BUF_SZ	1536	/* Size of each temporary Rx buffer.*/
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -226,9 +227,9 @@
 MODULE_DESCRIPTION("VIA Rhine PCI Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(debug, "i");
-MODULE_PARM(rx_copybreak, "i");
+module_param(max_interrupt_work, int, 0);
+module_param(debug, int, 0);
+module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(max_interrupt_work, "VIA Rhine maximum events handled per interrupt");
 MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
 MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy-only-tiny-frames");
# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/15 12:46:45-07:00 shemminger@zqx3.pdx.osdl.net 
#   use module_param
# 
# drivers/net/typhoon.c
#   2004/10/15 12:46:34-07:00 shemminger@zqx3.pdx.osdl.net +2 -1
#   use module_param
# 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2004-10-15 12:46:59 -07:00
+++ b/drivers/net/typhoon.c	2004-10-15 12:46:59 -07:00
@@ -99,6 +99,7 @@
 #define ERR_PFX			KERN_ERR PFX
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -132,7 +133,7 @@
 MODULE_AUTHOR("David Dillow <dave@thedillows.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("3Com Typhoon Family (3C990, 3CR990, and variants)");
-MODULE_PARM(rx_copybreak, "i");
+module_param(rx_copybreak, int, 0);
 
 #if defined(NETIF_F_TSO) && MAX_SKB_FRAGS > 32
 #warning Typhoon only supports 32 entries in its SG list for TSO, disabling TSO

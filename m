From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 1/2] via-rhine: use module_param
Date: Fri, 15 Oct 2004 13:58:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015135820.19747027@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use module_param here

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

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 1/2] b44: replace MODULE_PARM
Date: Fri, 15 Oct 2004 13:02:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015130257.4035b65c@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace MODULE_PARM with module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c	2004-10-15 12:23:11 -07:00
+++ b/drivers/net/b44.c	2004-10-15 12:23:11 -07:00
@@ -8,6 +8,7 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
@@ -79,10 +80,10 @@
 MODULE_AUTHOR("Florian Schirmer, Pekka Pietikainen, David S. Miller");
 MODULE_DESCRIPTION("Broadcom 4400 10/100 PCI ethernet driver");
 MODULE_LICENSE("GPL");
-MODULE_PARM(b44_debug, "i");
-MODULE_PARM_DESC(b44_debug, "B44 bitmapped debugging message enable value");
 
 static int b44_debug = -1;	/* -1 == use B44_DEF_MSG_ENABLE as value */
+module_param(b44_debug, int, 0);
+MODULE_PARM_DESC(b44_debug, "B44 bitmapped debugging message enable value");
 
 static struct pci_device_id b44_pci_tbl[] = {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401,

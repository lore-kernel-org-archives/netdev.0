From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ethertap module_param
Date: Wed, 28 Jul 2004 11:39:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728113910.3c7cab65@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change ethertap to use module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/ethertap.c b/drivers/net/ethertap.c
--- a/drivers/net/ethertap.c	2004-07-23 13:29:32 -07:00
+++ b/drivers/net/ethertap.c	2004-07-23 13:29:32 -07:00
@@ -13,7 +13,7 @@
  
 #include <linux/config.h>
 #include <linux/module.h>
-
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/slab.h>
@@ -45,7 +45,7 @@
 static int ethertap_debug;
 
 static int max_taps = 1;
-MODULE_PARM(max_taps, "i");
+module_param(max_taps, int, 0);
 MODULE_PARM_DESC(max_taps,"Max number of ethernet tap devices");
 
 static struct net_device **tap_map;	/* Returns the tap device for a given netlink */

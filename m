From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] convert netrom to module_param
Date: Thu, 29 Jul 2004 11:36:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729113651.6517fe27@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Ralf Baechel <ralf@linux-mips.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert Netrom to use module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
--- a/net/netrom/af_netrom.c	2004-07-23 13:27:52 -07:00
+++ b/net/netrom/af_netrom.c	2004-07-23 13:27:52 -07:00
@@ -10,6 +10,7 @@
  */
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -1451,8 +1452,7 @@
 
 module_init(nr_proto_init);
 
-
-MODULE_PARM(nr_ndevs, "i");
+module_param(nr_ndevs, int, 0);
 MODULE_PARM_DESC(nr_ndevs, "number of NET/ROM devices");
 
 MODULE_AUTHOR("Jonathan Naylor G4KLX <g4klx@g4klx.demon.co.uk>");

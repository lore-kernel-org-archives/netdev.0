From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] convert pktgen to module_param
Date: Wed, 28 Jul 2004 11:40:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728114037.7bad51e2@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Robert Olsson
 <robert.olsson@its.uu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert packet generator to module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/core/pktgen.c b/net/core/pktgen.c
--- a/net/core/pktgen.c	2004-07-23 13:26:21 -07:00
+++ b/net/core/pktgen.c	2004-07-23 13:26:21 -07:00
@@ -56,6 +56,7 @@
  */
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/types.h>
@@ -1409,7 +1410,7 @@
 MODULE_AUTHOR("Robert Olsson <robert.olsson@its.uu.se");
 MODULE_DESCRIPTION("Packet Generator tool");
 MODULE_LICENSE("GPL");
-MODULE_PARM(count_d, "i");
-MODULE_PARM(ipg_d, "i");
-MODULE_PARM(cpu_speed, "i");
-MODULE_PARM(clone_skb_d, "i");
+module_param(count_d, int, 0);
+module_param(ipg_d, int, 0);
+module_param(cpu_speed, int, 0);
+module_param(clone_skb_d, int, 0);

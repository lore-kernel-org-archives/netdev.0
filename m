From: akpm@osdl.org
Subject: [patch 10/13] drivers/net/sis900.c: fix a warning
Date: Tue, 15 Mar 2005 14:22:46 -0800
Message-ID: <200503152222.j2FMMfEI016820@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, bunk@stusta.de
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Adrian Bunk <bunk@stusta.de>

drivers/net/sis900.c:199: warning: 'sis900_poll' declared `static' but never defined

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/sis900.c |    2 ++
 1 files changed, 2 insertions(+)

diff -puN drivers/net/sis900.c~drivers-net-sis900c-fix-a-warning drivers/net/sis900.c
--- 25/drivers/net/sis900.c~drivers-net-sis900c-fix-a-warning	Tue Mar 15 14:19:54 2005
+++ 25-akpm/drivers/net/sis900.c	Tue Mar 15 14:19:54 2005
@@ -196,7 +196,9 @@ MODULE_PARM_DESC(multicast_filter_limit,
 MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled per interrupt");
 MODULE_PARM_DESC(sis900_debug, "SiS 900/7016 bitmapped debugging message level");
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
 static void sis900_poll(struct net_device *dev);
+#endif
 static int sis900_open(struct net_device *net_dev);
 static int sis900_mii_probe (struct net_device * net_dev);
 static void sis900_init_rxfilter (struct net_device * net_dev);
_

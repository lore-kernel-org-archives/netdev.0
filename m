From: akpm@osdl.org
Subject: [patch 5/9] ethertap debug no newline
Date: Thu, 28 Oct 2004 00:19:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410280721.i9S7Lh908000@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Andrew Hendry <ahendry@tusc.com.au>

Very trivial, ethertap debug missing a newline.

Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/ethertap.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/ethertap.c~ethertap-debug-no-newline drivers/net/ethertap.c
--- 25/drivers/net/ethertap.c~ethertap-debug-no-newline	2004-10-28 00:17:08.041581480 -0700
+++ 25-akpm/drivers/net/ethertap.c	2004-10-28 00:17:08.045580872 -0700
@@ -124,7 +124,7 @@ static int ethertap_open(struct net_devi
 	struct net_local *lp = netdev_priv(dev);
 
 	if (ethertap_debug > 2)
-		printk(KERN_DEBUG "%s: Doing ethertap_open()...", dev->name);
+		printk(KERN_DEBUG "%s: Doing ethertap_open()...\n", dev->name);
 
 	lp->nl = netlink_kernel_create(dev->base_addr, ethertap_rx);
 	if (lp->nl == NULL)
_

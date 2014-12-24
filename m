From: Kevin Hao <haokexin@gmail.com>
Subject: [PATCH net-next 1/2] net: gianfar: mark the local functions static
Date: Wed, 24 Dec 2014 14:05:44 +0800
Message-ID: <1419401145-8967-1-git-send-email-haokexin@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:53025 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbaLXGGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 01:06:47 -0500
Received: by mail-pd0-f173.google.com with SMTP id ft15so9319445pdb.32
        for <netdev@vger.kernel.org>; Tue, 23 Dec 2014 22:06:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Kevin Hao <haokexin@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 5645342f5b28..d2a67ed10a38 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -116,7 +116,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void gfar_reset_task(struct work_struct *work);
 static void gfar_timeout(struct net_device *dev);
 static int gfar_close(struct net_device *dev);
-struct sk_buff *gfar_new_skb(struct net_device *dev, dma_addr_t *bufaddr);
+static struct sk_buff *gfar_new_skb(struct net_device *dev,
+				    dma_addr_t *bufaddr);
 static int gfar_set_mac_address(struct net_device *dev);
 static int gfar_change_mtu(struct net_device *dev, int new_mtu);
 static irqreturn_t gfar_error(int irq, void *dev_id);
@@ -554,7 +555,7 @@ static void gfar_ints_enable(struct gfar_private *priv)
 	}
 }
 
-void lock_tx_qs(struct gfar_private *priv)
+static void lock_tx_qs(struct gfar_private *priv)
 {
 	int i;
 
@@ -562,7 +563,7 @@ void lock_tx_qs(struct gfar_private *priv)
 		spin_lock(&priv->tx_queue[i]->txlock);
 }
 
-void unlock_tx_qs(struct gfar_private *priv)
+static void unlock_tx_qs(struct gfar_private *priv)
 {
 	int i;
 
@@ -2671,7 +2672,7 @@ static struct sk_buff *gfar_alloc_skb(struct net_device *dev)
 	return skb;
 }
 
-struct sk_buff *gfar_new_skb(struct net_device *dev, dma_addr_t *bufaddr)
+static struct sk_buff *gfar_new_skb(struct net_device *dev, dma_addr_t *bufaddr)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb;
-- 
1.9.3

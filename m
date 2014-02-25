From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [net-next v2 2/3] net: bcmgenet: remove commented code in bcmgenet_xmit()
Date: Mon, 24 Feb 2014 16:56:12 -0800
Message-ID: <1393289773-9473-3-git-send-email-f.fainelli@gmail.com>
References: <1393289773-9473-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:12410 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948AbaBYA4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:56:24 -0500
In-Reply-To: <1393289773-9473-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code is commented since it is unused, left-over from the very first
time this driver was merged.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- respin

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 5856457..72ce6e8 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1145,10 +1145,6 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
-	/* reclaim xmited skb every 8 packets. */
-	/*if (ring->free_bds < ring->size - 8)*/
-		/*__bcmgenet_tx_reclaim(dev, ring);*/
-
 	/* set the SKB transmit checksum */
 	if (priv->desc_64b_en) {
 		ret = bcmgenet_put_tx_csum(dev, skb);
-- 
1.8.3.2

From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: [PATCH] net: ethernet: davinci: Fix build breakage
Date: Mon, 21 Jan 2013 10:38:39 +0100
Message-ID: <1358761119-25846-1-git-send-email-thierry.reding@avionic-design.de>
Cc: Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The correct name of the transmit DMA channel field in struct emac_priv
is txchan, not txch.

Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
---
 drivers/net/ethernet/ti/davinci_emac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 1c97c81..242ec55 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1102,7 +1102,7 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 	/* If there is no more tx desc left free then we need to
 	 * tell the kernel to stop sending us tx frames.
 	 */
-	if (unlikely(cpdma_check_free_tx_desc(priv->txch)))
+	if (unlikely(cpdma_check_free_tx_desc(priv->txchan)))
 		netif_stop_queue(ndev);
 
 	return NETDEV_TX_OK;
-- 
1.8.1.1

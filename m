From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 11/17] net: stmmac: Rewrite two test against NULL value
Date: Tue, 31 Jan 2017 10:11:46 +0100
Message-ID: <20170131091152.13842-12-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch rewrite two test against NULL value with correct style.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b0154d5..2df36bd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -700,7 +700,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 	int new_state = 0;
 	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
 
-	if (phydev == NULL)
+	if (!phydev)
 		return;
 
 	spin_lock_irqsave(&priv->lock, flags);
@@ -1143,7 +1143,7 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 						 DMA_TO_DEVICE);
 		}
 
-		if (priv->tx_skbuff[i] != NULL) {
+		if (priv->tx_skbuff[i]) {
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
 			priv->tx_skbuff_dma[i].buf = 0;
-- 
2.10.2

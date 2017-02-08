From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 11/16] net: stmmac: Rewrite two test against NULL value
Date: Wed,  8 Feb 2017 09:31:16 +0100
Message-ID: <20170208083121.27949-12-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch rewrite two test against NULL value with correct style.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ed81375..cc88bdb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -689,7 +689,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 	int new_state = 0;
 	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
 
-	if (phydev == NULL)
+	if (!phydev)
 		return;
 
 	spin_lock_irqsave(&priv->lock, flags);
@@ -1131,7 +1131,7 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 						 DMA_TO_DEVICE);
 		}
 
-		if (priv->tx_skbuff[i] != NULL) {
+		if (priv->tx_skbuff[i]) {
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
 			priv->tx_skbuff_dma[i].buf = 0;
-- 
2.10.2

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH] net: stmmac: fix double-initialization of phy_iface
Date: Thu,  5 Nov 2015 10:26:46 +0100
Message-ID: <1446715606-10326-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable phy_iface is double-initialized to itself.
This patch remove that.

Reported-by: coverity (CID 1271141)
Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
index 11baa4b..0cd3ecf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -354,7 +354,7 @@ static int gmac_clk_init(struct rk_priv_data *bsp_priv)
 
 static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool enable)
 {
-	int phy_iface = phy_iface = bsp_priv->phy_iface;
+	int phy_iface = bsp_priv->phy_iface;
 
 	if (enable) {
 		if (!bsp_priv->clk_enabled) {
-- 
2.4.10

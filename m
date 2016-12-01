From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 1/2] net: stmmac: avoid Camelcase naming
Date: Thu,  1 Dec 2016 16:19:40 +0100
Message-ID: <1480605581-13350-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch simply rename regValue to value, like it was named in other
mdio functions.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index e3216e5..6796c28 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -83,14 +83,14 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
 	unsigned int mii_data = priv->hw->mii.data;
 
 	int data;
-	u16 regValue = (((phyaddr << 11) & (0x0000F800)) |
+	u16 value = (((phyaddr << 11) & (0x0000F800)) |
 			((phyreg << 6) & (0x000007C0)));
-	regValue |= MII_BUSY | ((priv->clk_csr & 0xF) << 2);
+	value |= MII_BUSY | ((priv->clk_csr & 0xF) << 2);
 
 	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
 		return -EBUSY;
 
-	writel(regValue, priv->ioaddr + mii_address);
+	writel(value, priv->ioaddr + mii_address);
 
 	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
 		return -EBUSY;
-- 
2.7.3

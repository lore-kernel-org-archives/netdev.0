From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 1/8] net: stmmac: remove useless parenthesis
Date: Wed, 15 Feb 2017 10:46:38 +0100
Message-ID: <20170215094645.591-2-clabbe.montjoie@gmail.com>
References: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch remove some useless parenthesis.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 8 ++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7251871..ee1dbf4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -716,15 +716,15 @@ static void stmmac_adjust_link(struct net_device *dev)
 			new_state = 1;
 			switch (phydev->speed) {
 			case 1000:
-				if (likely((priv->plat->has_gmac) ||
-					   (priv->plat->has_gmac4)))
+				if (likely(priv->plat->has_gmac ||
+					   priv->plat->has_gmac4))
 					ctrl &= ~priv->hw->link.port;
 				stmmac_hw_fix_mac_speed(priv);
 				break;
 			case 100:
 			case 10:
-				if (likely((priv->plat->has_gmac) ||
-					   (priv->plat->has_gmac4))) {
+				if (likely(priv->plat->has_gmac ||
+					   priv->plat->has_gmac4)) {
 					ctrl |= priv->hw->link.port;
 					if (phydev->speed == SPEED_100) {
 						ctrl |= priv->hw->link.speed;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index d9893cf..a695773 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -257,7 +257,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 			 * If an IRQ was provided to be assigned after
 			 * the bus probe, do it here.
 			 */
-			if ((!mdio_bus_data->irqs) &&
+			if (!mdio_bus_data->irqs &&
 			    (mdio_bus_data->probed_phy_irq > 0)) {
 				new_bus->irq[addr] =
 					mdio_bus_data->probed_phy_irq;
-- 
2.10.2

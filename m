From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 3/4] net-next: stmmac: use SPEED_xxx instead of raw value
Date: Mon, 22 May 2017 14:33:46 +0200
Message-ID: <20170522123347.5295-4-clabbe.montjoie@gmail.com>
References: <20170522123347.5295-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170522123347.5295-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 190686e39835..9bf09100c199 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -812,12 +812,12 @@ static void stmmac_adjust_link(struct net_device *dev)
 		if (phydev->speed != priv->speed) {
 			new_state = true;
 			switch (phydev->speed) {
-			case 1000:
+			case SPEED_1000:
 				if (priv->plat->has_gmac ||
 				    priv->plat->has_gmac4)
 					ctrl &= ~priv->hw->link.port;
 				break;
-			case 100:
+			case SPEED_100:
 				if (priv->plat->has_gmac ||
 				    priv->plat->has_gmac4) {
 					ctrl |= priv->hw->link.port;
@@ -826,7 +826,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 					ctrl &= ~priv->hw->link.port;
 				}
 				break;
-			case 10:
+			case SPEED_10:
 				if (priv->plat->has_gmac ||
 				    priv->plat->has_gmac4) {
 					ctrl |= priv->hw->link.port;
-- 
2.13.0

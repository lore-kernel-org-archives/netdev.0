From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 10/16] net: stmmac: Correct the error message about invalid speed
Date: Wed,  8 Feb 2017 09:31:15 +0100
Message-ID: <20170208083121.27949-11-clabbe.montjoie@gmail.com>
References: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Cc: linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208083121.27949-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The message about invalid speed does not state 1000 as a valid speed.
It is much simpler to said that the speed is invalid.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a13fcc4..ed81375 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -738,8 +738,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 				break;
 			default:
 				netif_warn(priv, link, priv->dev,
-					   "Speed (%d) not 10/100\n",
-					   phydev->speed);
+					   "broken speed: %d\n", phydev->speed);
 				break;
 			}
 
-- 
2.10.2

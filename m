From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 2/4] net-next: stmmac: Remove unnecessary parenthesis
Date: Mon, 22 May 2017 14:33:45 +0200
Message-ID: <20170522123347.5295-3-clabbe.montjoie@gmail.com>
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
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 94b37323844b..190686e39835 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -799,7 +799,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = true;
-			if (!(phydev->duplex))
+			if (!phydev->duplex)
 				ctrl &= ~priv->hw->link.duplex;
 			else
 				ctrl |= priv->hw->link.duplex;
-- 
2.13.0

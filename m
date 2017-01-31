From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 10/17] net: stmmac: Correct the error message about invalid speed
Date: Tue, 31 Jan 2017 10:11:45 +0100
Message-ID: <20170131091152.13842-11-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add 1000 as a valid speed in the error message about invalid speed
in stmmac_adjust_link()

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 98f544e..b0154d5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -749,7 +749,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 				break;
 			default:
 				netif_warn(priv, link, priv->dev,
-					   "Speed (%d) not 10/100\n",
+					   "Speed (%d) not 10/100/1000\n",
 					   phydev->speed);
 				break;
 			}
-- 
2.10.2

From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 2/5] net: stmmac: replace hardcoded function name by __func__
Date: Thu,  5 Nov 2015 14:14:09 +0100
Message-ID: <1446729252-9160-3-git-send-email-clabbe.montjoie@gmail.com>
References: <1446729252-9160-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446729252-9160-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some printing have the function name hardcoded.
It is better to use __func__ instead.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 633a47d..911cf28 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -833,7 +833,7 @@ static int stmmac_init_phy(struct net_device *dev)
 
 		snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
 			 priv->plat->phy_addr);
-		netdev_dbg(priv->dev, "stmmac_init_phy: trying to attach to %s\n",
+		netdev_dbg(priv->dev, "%s: trying to attach to %s\n", __func__,
 			   phy_id_fmt);
 
 		phydev = phy_connect(dev, phy_id_fmt, &stmmac_adjust_link,
@@ -866,8 +866,8 @@ static int stmmac_init_phy(struct net_device *dev)
 		phy_disconnect(phydev);
 		return -ENODEV;
 	}
-	netdev_dbg(priv->dev, "stmmac_init_phy: attached to PHY (UID 0x%x) Link = %d\n",
-		   phydev->phy_id, phydev->link);
+	netdev_dbg(priv->dev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
+		   __func__, phydev->phy_id, phydev->link);
 
 	priv->phydev = phydev;
 
-- 
2.4.10

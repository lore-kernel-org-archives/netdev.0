From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 1/4] net-next: stmmac: Convert new_state to bool
Date: Fri, 19 May 2017 09:03:32 +0200
Message-ID: <20170519070335.1604-2-clabbe.montjoie@gmail.com>
References: <20170519070335.1604-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170519070335.1604-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch convert new_state from int to bool since it store only 1 or 0

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1da17cd519f6..2b778f63d1d5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -785,7 +785,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
-	int new_state = 0;
+	bool new_state = 0;
 
 	if (!phydev)
 		return;
-- 
2.13.0

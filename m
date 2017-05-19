From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 3/4] net-next: stmmac: use SPEED_xxx instead of raw value
Date: Fri, 19 May 2017 09:03:34 +0200
Message-ID: <20170519070335.1604-4-clabbe.montjoie@gmail.com>
References: <20170519070335.1604-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:35956 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdESHFs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 03:05:48 -0400
In-Reply-To: <20170519070335.1604-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e008cded388e..a1ab52e29359 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -812,12 +812,12 @@ static void stmmac_adjust_link(struct net_device *dev)
 		if (phydev->speed != priv->speed) {
 			new_state = 1;
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

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 3/5] net-next: stmmac: use SPEED_xxx instead of raw value
Date: Wed, 24 May 2017 09:16:45 +0200
Message-ID: <20170524071647.7921-4-clabbe.montjoie@gmail.com>
References: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33484 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938682AbdEXHTN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 03:19:13 -0400
In-Reply-To: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1fb46c124ab1..5643a5c916b6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -813,12 +813,12 @@ static void stmmac_adjust_link(struct net_device *dev)
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
@@ -827,7 +827,7 @@ static void stmmac_adjust_link(struct net_device *dev)
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

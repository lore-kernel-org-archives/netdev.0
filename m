From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 2/4] net-next: stmmac: Remove unnecessary parenthesis
Date: Fri, 19 May 2017 09:03:33 +0200
Message-ID: <20170519070335.1604-3-clabbe.montjoie@gmail.com>
References: <20170519070335.1604-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33795 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751190AbdESHFs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 03:05:48 -0400
In-Reply-To: <20170519070335.1604-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 2b778f63d1d5..e008cded388e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -799,7 +799,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = 1;
-			if (!(phydev->duplex))
+			if (!phydev->duplex)
 				ctrl &= ~priv->hw->link.duplex;
 			else
 				ctrl |= priv->hw->link.duplex;
-- 
2.13.0

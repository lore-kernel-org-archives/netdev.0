From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/4] stmmac: use MII_BUS_ID_SIZE instead of  BUS_ID_SIZE
Date: Thu,  3 Dec 2009 11:40:04 +0100
Message-ID: <1259836805-7512-3-git-send-email-peppe.cavallaro@st.com>
References: <1259836805-7512-1-git-send-email-peppe.cavallaro@st.com>
 <1259836805-7512-2-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:59957 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754758AbZLCKkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 05:40:46 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BCA0822F
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 10:40:49 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7F113A6C
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 10:40:49 +0000 (GMT)
In-Reply-To: <1259836805-7512-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/stmmac/stmmac_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index d9cad02..59905b7 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -304,8 +304,8 @@ static int stmmac_init_phy(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev;
-	char phy_id[BUS_ID_SIZE];	/* PHY to connect */
-	char bus_id[BUS_ID_SIZE];
+	char phy_id[MII_BUS_ID_SIZE + 3];
+	char bus_id[MII_BUS_ID_SIZE];
 
 	priv->oldlink = 0;
 	priv->speed = 0;
@@ -317,7 +317,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	}
 
 	snprintf(bus_id, MII_BUS_ID_SIZE, "%x", priv->bus_id);
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, bus_id, priv->phy_addr);
+	snprintf(phy_id, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id, priv->phy_addr);
 	pr_debug("stmmac_init_phy:  trying to attach to %s\n", phy_id);
 
 	phydev = phy_connect(dev, phy_id, &stmmac_adjust_link, 0,
-- 
1.6.0.4


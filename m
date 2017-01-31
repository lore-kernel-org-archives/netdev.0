From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 14/17] net: stmmac: print phy information
Date: Tue, 31 Jan 2017 10:11:49 +0100
Message-ID: <20170131091152.13842-15-clabbe.montjoie@gmail.com>
References: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:35680 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751149AbdAaJsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 04:48:19 -0500
In-Reply-To: <20170131091152.13842-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a PHY is found, printing which one was found (and which type/model) is
a good information to know.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e53b727..3d52b8c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -885,6 +885,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	netdev_dbg(priv->dev, "%s: attached to PHY (UID 0x%x) Link = %d\n",
 		   __func__, phydev->phy_id, phydev->link);
 
+	phy_attached_info(phydev);
 	return 0;
 }
 
-- 
2.10.2

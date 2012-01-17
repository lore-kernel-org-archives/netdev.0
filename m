From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH] net: sh-eth: Fix build error by the value which is not defined
Date: Tue, 17 Jan 2012 11:50:16 +0900
Message-ID: <1326768616-14182-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: florian@openwrt.org,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52932 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab2AQCql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2012 21:46:41 -0500
Received: by iagf6 with SMTP id f6so3500752iag.19
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2012 18:46:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----
drivers/net/ethernet/renesas/sh_eth.c:1706: error: 'pdid' undeclared (first use in this function)
drivers/net/ethernet/renesas/sh_eth.c:1706: error: (Each undeclared identifier is reported only once
drivers/net/ethernet/renesas/sh_eth.c:1706: error: for each function it appears in.)
make[5]: *** [drivers/net/ethernet/renesas/sh_eth.o] Error 1
-----

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
CC: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 6ece429..813d41c 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1703,7 +1703,7 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 	mdp->mii_bus->name = "sh_mii";
 	mdp->mii_bus->parent = &ndev->dev;
 	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		mdp->pdev->name, pdid);
+		mdp->pdev->name, id);
 
 	/* PHY IRQ */
 	mdp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-- 
1.7.7.3

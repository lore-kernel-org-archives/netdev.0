From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/3] net: sh_eth: Fix a typo - replace regist with register.
Date: Mon, 17 Sep 2001 00:00:00 +0900
Message-ID: <201211021439.qA2EdfnI004714@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58901 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab2KBOpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 10:45:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c8bfea0..3d70586 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -2286,7 +2286,7 @@ static int sh_mdio_init(struct net_device *ndev, int id,
 	for (i = 0; i < PHY_MAX_ADDR; i++)
 		mdp->mii_bus->irq[i] = PHY_POLL;
 
-	/* regist mdio bus */
+	/* register mdio bus */
 	ret = mdiobus_register(mdp->mii_bus);
 	if (ret)
 		goto out_free_irq;
-- 
1.7.9.5

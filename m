From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH] net: au1000 eth: simplify logical expression
Date: Wed, 18 May 2016 01:58:45 +0200
Message-ID: <1463529525-12504-1-git-send-email-xypron.glpk@gmx.de>
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ivan Vecera <ivecera@redhat.com>,
	Antonio Quartulli <a@unstable.cc>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:63019 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbcEQX7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 19:59:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(a && a > 0) is equivalent to (a > 0).

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/amd/au1000_eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 9af309e..e0fb0f1 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1269,7 +1269,7 @@ static int au1000_probe(struct platform_device *pdev)
 		aup->phy_irq = pd->phy_irq;
 	}
 
-	if (aup->phy_busid && aup->phy_busid > 0) {
+	if (aup->phy_busid > 0) {
 		dev_err(&pdev->dev, "MAC0-associated PHY attached 2nd MACs MII bus not supported yet\n");
 		err = -ENODEV;
 		goto err_mdiobus_alloc;
-- 
2.1.4

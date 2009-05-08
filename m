From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [PATCH] net/fs_enet/mii-fec: Use PHY_POLL instead of hard coded '-1'
Date: Fri,  8 May 2009 16:00:01 +0200
Message-ID: <1241791201-23960-1-git-send-email-w.sang@pengutronix.de>
Cc: Vitaly Bordug <vbordug@ru.mvista.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: w.sang@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48643 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbZEHOAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 10:00:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize the irq-table with PHY_POLL. '-1' means the same now, but is
hardly maintainable.

Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Cc: Vitaly Bordug <vbordug@ru.mvista.com>
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: netdev@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org
---
 drivers/net/fs_enet/mii-fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 28077cc..9eb5480 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -166,7 +166,7 @@ static int __devinit fs_enet_mdio_probe(struct of_device *ofdev,
 		goto out_unmap_regs;
 
 	for (i = 0; i < PHY_MAX_ADDR; i++)
-		new_bus->irq[i] = -1;
+		new_bus->irq[i] = PHY_POLL;
 
 	while ((np = of_get_next_child(ofdev->node, np)))
 		if (!strcmp(np->type, "ethernet-phy"))
-- 
1.6.2


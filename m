From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH] net: davinci_emac: Remove unwanted debug/error message
Date: Tue,  3 Jun 2014 06:16:18 +0200
Message-ID: <1401768978-22284-1-git-send-email-christian.riesch@omicron.at>
Cc: Christian Riesch <christian.riesch@omicron.at>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay02.ispgateway.de ([80.67.31.36]:60726 "EHLO
	smtprelay02.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbaFCEWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 00:22:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit cd11cf505318ff24e42f35145f9cdf8596fa1958 I accidentally
added an error message. I used it for debugging and forgot to remove
it before submitting the patch.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/ethernet/ti/davinci_emac.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 8f0e69c..abc286d 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1567,7 +1567,6 @@ static int emac_dev_open(struct net_device *ndev)
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ,
 					    res_num))) {
 		for (irq_num = res->start; irq_num <= res->end; irq_num++) {
-			dev_err(emac_dev, "Request IRQ %d\n", irq_num);
 			if (request_irq(irq_num, emac_irq, 0, ndev->name,
 					ndev)) {
 				dev_err(emac_dev,
-- 
1.7.9.5

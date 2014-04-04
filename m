From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: [PATCH] net: smc911x: Remove unused local variable
Date: Fri,  4 Apr 2014 02:16:23 +0200
Message-ID: <1396570583-6564-1-git-send-email-laurent.pinchart@ideasonboard.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perceval.ideasonboard.com ([95.142.166.194]:52906 "EHLO
	perceval.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbaDDAOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 20:14:23 -0400
Received: from avalon.ideasonboard.com (unknown [91.177.168.144])
	by perceval.ideasonboard.com (Postfix) with ESMTPSA id 3E0DF359AC
	for <netdev@vger.kernel.org>; Fri,  4 Apr 2014 02:12:38 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ioaddr local variable is assigned to but never used in the
smc911x_rx_dma_irq() function, remove it.

Signed-off-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
---
 drivers/net/ethernet/smsc/smc911x.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index c50fb08..50b4d83 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1211,7 +1211,6 @@ static void
 smc911x_rx_dma_irq(int dma, void *data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	unsigned long ioaddr = dev->base_addr;
 	struct smc911x_local *lp = netdev_priv(dev);
 	struct sk_buff *skb = lp->current_rx_skb;
 	unsigned long flags;
-- 
Regards,

Laurent Pinchart

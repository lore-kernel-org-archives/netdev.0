From: Daniel Mack <zonque@gmail.com>
Subject: [PATCH] net: ethernet: davinci_cpdma: export cpdma_chan_get_stats
Date: Thu, 22 Aug 2013 13:47:00 +0200
Message-ID: <1377172020-28053-1-git-send-email-zonque@gmail.com>
Cc: davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	Daniel Mack <zonque@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:46184 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab3HVLrK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:47:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed when the cpsw driver is built as module.

Signed-off-by: Daniel Mack <zonque@gmail.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 031ebc8..90a7946 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -591,6 +591,7 @@ int cpdma_chan_get_stats(struct cpdma_chan *chan,
 	spin_unlock_irqrestore(&chan->lock, flags);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(cpdma_chan_get_stats);
 
 int cpdma_chan_dump(struct cpdma_chan *chan)
 {
-- 
1.8.3.1

From: Chuck Ebbert <76306.1226@compuserve.com>
Subject: [dropped? patch] netdev: fix smc911 compile error
Date: Sat, 23 Dec 2006 14:57:44 -0500
Message-ID: <200612231501_MC3-1-D628-DCA5@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain;
	 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from liaag1aa.mx.compuserve.com ([149.174.40.27]:35723 "EHLO
	liaag1aa.mx.compuserve.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753734AbWLWUKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Dec 2006 15:10:06 -0500
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vitaly Wool <vitalywool@gmail.com>

Fix compilation failure for smc911x.c when NET_POLL_CONTROLLER is set.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
Is not upstream and doesn't seem to be in upstream-fixes either.

--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1331,7 +1331,7 @@ smc911x_rx_dma_irq(int dma, void *data)
 static void smc911x_poll_controller(struct net_device *dev)
 {
 	disable_irq(dev->irq);
-	smc911x_interrupt(dev->irq, dev, NULL);
+	smc911x_interrupt(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif

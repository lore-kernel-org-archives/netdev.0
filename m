From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH] smc911x: fix netpoll compilation faliure
Date: Fri, 15 Dec 2006 16:13:28 +0300
Message-ID: <20061215161328.9797232d.vitalywool@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:40501 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1752107AbWLONUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 08:20:03 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello folks,

the trivial patch below fixes the compilation failure for smc911x.c when NET_POLL_CONTROLLER is set.

 drivers/net/smc911x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 2c43433..797ab91 100644
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

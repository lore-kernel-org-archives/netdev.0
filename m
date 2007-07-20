From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 7/10] ps3: use ethX as the name of irq
Date: Fri, 20 Jul 2007 17:33:02 +0900
Message-ID: <20070720173121.679B.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:34961 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937492AbXGTIdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:33:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use net_device name for registration of irq as many network drivers do.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1073,7 +1073,7 @@ static int gelic_net_open_device(struct 
 	}
 
 	result = request_irq(card->netdev->irq, gelic_net_interrupt,
-			     IRQF_DISABLED, "gelic network", card->netdev);
+			     IRQF_DISABLED, card->netdev->name, card->netdev);
 
 	if (result) {
 		dev_info(ctodev(card), "%s:%d: request_irq failed (%d)\n",

--
Masakazu MOKUNO


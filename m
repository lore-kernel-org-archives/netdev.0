From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net/hsr: use eth_hw_addr_random()
Date: Tue, 21 Feb 2017 14:04:59 +0100
Message-ID: <20170221130459.5873-1-tklauser@distanz.ch>
To: arvid.brodin@alten.se, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:48036 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752619AbdBUNFG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 08:05:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_hw_addr_random() to set a random MAC address in order to make sure
dev->addr_assign_type will be properly set to NET_ADDR_RANDOM.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/hsr/hsr_device.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index fc65b145f6e7..c73160fb11e7 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -395,7 +395,7 @@ static struct device_type hsr_type = {
 
 void hsr_dev_setup(struct net_device *dev)
 {
-	random_ether_addr(dev->dev_addr);
+	eth_hw_addr_random(dev);
 
 	ether_setup(dev);
 	dev->min_mtu = 0;
-- 
2.11.0

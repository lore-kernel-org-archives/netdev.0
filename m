From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH net-next] macsec: Convert to using IFF_NO_QUEUE
Date: Fri, 22 Apr 2016 14:02:42 +0200
Message-ID: <1461326562-6595-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:49681 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbcDVMCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 08:02:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/net/macsec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 84d3e5ca88171..6caa72402de7d 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -2826,7 +2826,7 @@ static void macsec_free_netdev(struct net_device *dev)
 static void macsec_setup(struct net_device *dev)
 {
 	ether_setup(dev);
-	dev->tx_queue_len = 0;
+	dev->priv_flags |= IFF_NO_QUEUE;
 	dev->netdev_ops = &macsec_netdev_ops;
 	dev->destructor = macsec_free_netdev;
 
-- 
2.8.0

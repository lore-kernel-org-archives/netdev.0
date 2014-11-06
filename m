From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH 1/2 net-next] sunvnet: Fix indentation in maybe_tx_wakeup()
Date: Thu, 6 Nov 2014 14:51:02 -0500
Message-ID: <20141106195102.GE6238@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com,
	ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:27740 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbaKFTvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 14:51:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


remove redundant tab.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Reported-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/ethernet/sun/sunvnet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index e7bb63b..2688b19 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -627,7 +627,7 @@ static void maybe_tx_wakeup(struct vnet_port *port)
 		struct vio_dring_state *dr;
 
 		dr = &port->vio.drings[VIO_DRIVER_TX_RING];
-			netif_tx_wake_queue(txq);
+		netif_tx_wake_queue(txq);
 	}
 	__netif_tx_unlock(txq);
 }
-- 
1.8.4.2

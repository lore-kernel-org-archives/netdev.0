From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/2] drivers/net/ethernet/tundra/tsi108_eth.c: delete double assignment
Date: Sun, 26 Aug 2012 10:18:35 +0200
Message-ID: <1345969115-12977-2-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:5463 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751166Ab2HZISm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 04:18:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>

Delete successive assignments to the same location.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression i;
@@

*i = ...;
 i = ...;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/tundra/tsi108_eth.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 277c93e..8fa947a 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1359,7 +1359,6 @@ static int tsi108_open(struct net_device *dev)
 		}
 
 		data->rxskbs[i] = skb;
-		data->rxskbs[i] = skb;
 		data->rxring[i].buf0 = virt_to_phys(data->rxskbs[i]->data);
 		data->rxring[i].misc = TSI108_RX_OWN | TSI108_RX_INT;
 	}

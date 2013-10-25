From: Colin Rice <ricec2@rpi.edu>
Subject: [PATCH net-next] 3c515: Fix warning when building
Date: Fri, 25 Oct 2013 21:59:46 +0000
Message-ID: <1382738386-29888-1-git-send-email-ricec2@rpi.edu>
Cc: Colin Rice <ricec2@rpi.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.canit.rpi.edu ([128.113.2.229]:54343 "EHLO
	smtp9.server.rpi.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab3JYWHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 18:07:16 -0400
Received: from smtp-auth1.server.rpi.edu (smtp-auth1.server.rpi.edu [128.113.2.231])
	by smtp9.server.rpi.edu (8.14.3/8.14.3/Debian-9.4) with ESMTP id r9PLxqlC001539
	for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 17:59:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Colin Rice <ricec2@rpi.edu>
---
 drivers/net/ethernet/3com/3c515.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index 94c656f..33ffda4 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -1063,7 +1063,7 @@ static netdev_tx_t corkscrew_start_xmit(struct sk_buff *skb,
 #ifdef VORTEX_BUS_MASTER
 	if (vp->bus_master) {
 		/* Set the bus-master controller to transfer the packet. */
-		outl((int) (skb->data), ioaddr + Wn7_MasterAddr);
+		outl((size_t) (skb->data), ioaddr + Wn7_MasterAddr);
 		outw((skb->len + 3) & ~3, ioaddr + Wn7_MasterLen);
 		vp->tx_skb = skb;
 		outw(StartDMADown, ioaddr + EL3_CMD);
-- 
1.8.1.2

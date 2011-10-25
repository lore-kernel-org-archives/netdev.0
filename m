From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] net: ucc_geth, increase no. of HW RX descriptors
Date: Tue, 25 Oct 2011 15:17:10 +0200
Message-ID: <1319548630-6561-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: Anton Vorontsov <avorontsov@ru.mvista.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:46694 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933399Ab1JYN1P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Oct 2011 09:27:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a busy network we see ucc_geth is dropping RX pkgs every now
and then. Increase the first RX queues HW descriptors from
16 to 32 to deal with this.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index fa00935..04e22ff 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -134,7 +134,7 @@ static struct ucc_geth_info ugeth_primary_info = {
 			TX_BD_RING_LEN},
 
 	.bdRingLenRx = {
-			RX_BD_RING_LEN,
+			RX_BD_RING_LEN*2,
 			RX_BD_RING_LEN,
 			RX_BD_RING_LEN,
 			RX_BD_RING_LEN,
-- 
1.7.3.4

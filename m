From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 1/2] net: ucc_geth, increase no. of HW RX descriptors
Date: Mon, 30 Apr 2012 10:36:54 +0200
Message-ID: <1335775015-14718-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:54649 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab2D3IhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 04:37:10 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 0B5C525803A
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 10:37:08 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a busy network we see ucc_geth is dropping RX pkgs every now
and then. Increase the RX queues HW descriptors from
16 to 32 to deal with this.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ethernet/freescale/ucc_geth.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
index 2e395a2..f71b3e7 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.h
+++ b/drivers/net/ethernet/freescale/ucc_geth.h
@@ -877,7 +877,7 @@ struct ucc_geth_hardware_statistics {
 
 /* Driver definitions */
 #define TX_BD_RING_LEN                          0x10
-#define RX_BD_RING_LEN                          0x10
+#define RX_BD_RING_LEN                          0x20
 
 #define TX_RING_MOD_MASK(size)                  (size-1)
 #define RX_RING_MOD_MASK(size)                  (size-1)
-- 
1.7.3.4

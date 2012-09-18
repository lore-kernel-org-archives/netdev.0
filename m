From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 4/5] ucc_geth: Increase RX ring buffer from 32 to 64
Date: Tue, 18 Sep 2012 18:56:24 +0200
Message-ID: <1347987385-19071-4-git-send-email-Joakim.Tjernlund@transmode.se>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:65319 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751890Ab2IRQ4i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 12:56:38 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id B8A52258283
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 18:56:37 +0200 (CEST)
In-Reply-To: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We still see dropped pkgs in a busy network, this makes it better.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ethernet/freescale/ucc_geth.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
index aeb743c..b68637e 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.h
+++ b/drivers/net/ethernet/freescale/ucc_geth.h
@@ -878,7 +878,7 @@ struct ucc_geth_hardware_statistics {
 
 /* Driver definitions */
 #define TX_BD_RING_LEN                          0x10
-#define RX_BD_RING_LEN                          0x20
+#define RX_BD_RING_LEN                          0x40
 
 #define TX_RING_MOD_MASK(size)                  (size-1)
 #define RX_RING_MOD_MASK(size)                  (size-1)
-- 
1.7.8.6

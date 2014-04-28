From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] Altera TSE: Add missing include to silence sparse warnings
Date: Mon, 28 Apr 2014 11:40:08 +0200
Message-ID: <1398678008-7138-1-git-send-email-tklauser@distanz.ch>
Cc: nios2-dev@lists.rocketboards.org
To: Vince Bridgers <vbridgers2013@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:46172 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754232AbaD1JkM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 05:40:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following sparse warnings:

drivers/net/ethernet/altera/altera_msgdma.c:23:5: warning: symbol 'msgdma_initialize' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:28:6: warning: symbol 'msgdma_uninitialize' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:32:6: warning: symbol 'msgdma_reset' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:77:6: warning: symbol 'msgdma_disable_rxirq' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:83:6: warning: symbol 'msgdma_enable_rxirq' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:89:6: warning: symbol 'msgdma_disable_txirq' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:95:6: warning: symbol 'msgdma_enable_txirq' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:101:6: warning: symbol 'msgdma_clear_rxirq' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:107:6: warning: symbol 'msgdma_clear_txirq' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:114:5: warning: symbol 'msgdma_tx_buffer' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:129:5: warning: symbol 'msgdma_tx_completions' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:154:5: warning: symbol 'msgdma_add_rx_desc' was not declared. Should it be static?
drivers/net/ethernet/altera/altera_msgdma.c:181:5: warning: symbol 'msgdma_rx_status' was not declared. Should it be static?

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/altera/altera_msgdma.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/altera/altera_msgdma.c b/drivers/net/ethernet/altera/altera_msgdma.c
index 0e38a03..c463482 100644
--- a/drivers/net/ethernet/altera/altera_msgdma.c
+++ b/drivers/net/ethernet/altera/altera_msgdma.c
@@ -18,6 +18,7 @@
 #include "altera_utils.h"
 #include "altera_tse.h"
 #include "altera_msgdmahw.h"
+#include "altera_msgdma.h"
 
 /* No initialization work to do for MSGDMA */
 int msgdma_initialize(struct altera_tse_private *priv)
-- 
1.7.9.5

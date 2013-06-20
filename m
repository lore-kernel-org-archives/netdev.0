From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3/6] alx: make sizes unsigned
Date: Fri, 21 Jun 2013 00:14:51 +0200
Message-ID: <1371766494-18979-4-git-send-email-johannes@sipsolutions.net>
References: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
Cc: ben@decadent.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49183 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030334Ab3FTWPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 18:15:02 -0400
In-Reply-To: <1371766494-18979-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ring sizes should be unsigned, pointed out by Ben Hutchings.

Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/ethernet/atheros/alx/alx.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index 50b3ae2..d71103d 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -85,16 +85,16 @@ struct alx_priv {
 	struct {
 		dma_addr_t dma;
 		void *virt;
-		int size;
+		unsigned int size;
 	} descmem;
 
 	/* protect int_mask updates */
 	spinlock_t irq_lock;
 	u32 int_mask;
 
-	int tx_ringsz;
-	int rx_ringsz;
-	int rxbuf_size;
+	unsigned int tx_ringsz;
+	unsigned int rx_ringsz;
+	unsigned int rxbuf_size;
 
 	struct napi_struct napi;
 	struct alx_tx_queue txq;
-- 
1.8.0

From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 4/8] alx: make sizes unsigned
Date: Sat, 29 Jun 2013 19:23:16 +0200
Message-ID: <1372526600-15934-5-git-send-email-johannes@sipsolutions.net>
References: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58302 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab3F2RX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 13:23:26 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Usyrt-0006aE-A4
	for netdev@vger.kernel.org; Sat, 29 Jun 2013 19:23:25 +0200
In-Reply-To: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
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

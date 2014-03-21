From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next 3/3] Altera TSE: Correct two typos in original submission
Date: Thu, 20 Mar 2014 20:43:17 -0500
Message-ID: <1395366197-9781-4-git-send-email-vbridgers2013@gmail.com>
References: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:55100 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965239AbaCUBsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 21:48:05 -0400
Received: by mail-ob0-f170.google.com with SMTP id uz6so1869012obc.1
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 18:48:04 -0700 (PDT)
In-Reply-To: <1395366197-9781-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses two typos in the original driver submission. One derived
from a cut & paste error, and another is a misspelling.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
 drivers/net/ethernet/altera/altera_sgdma.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_sgdma.c b/drivers/net/ethernet/altera/altera_sgdma.c
index ebc4840..0ee9663 100644
--- a/drivers/net/ethernet/altera/altera_sgdma.c
+++ b/drivers/net/ethernet/altera/altera_sgdma.c
@@ -84,8 +84,8 @@ int sgdma_initialize(struct altera_tse_private *priv)
 		return -EINVAL;
 	}
 
-	priv->txdescphys = dma_map_single(priv->device, priv->rx_dma_desc,
-					  priv->rxdescmem, DMA_TO_DEVICE);
+	priv->txdescphys = dma_map_single(priv->device, priv->tx_dma_desc,
+					  priv->txdescmem, DMA_TO_DEVICE);
 
 	if (dma_mapping_error(priv->device, priv->txdescphys)) {
 		sgdma_uninitialize(priv);
@@ -340,7 +340,7 @@ static int sgdma_async_read(struct altera_tse_private *priv)
 		/* clear control and status */
 		iowrite32(0, &csr->control);
 
-		/* If statuc available, clear those bits */
+		/* If status available, clear those bits */
 		if (sts & 0xf)
 			iowrite32(0xf, &csr->status);
 
-- 
1.7.9.5

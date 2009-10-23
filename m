From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/27] sfc: Define DMA address mask explicitly in terms of
	descriptor field width
Date: Fri, 23 Oct 2009 19:31:07 +0100
Message-ID: <1256322667.2785.25.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8722 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbZJWSbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:31:05 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 3cb7e61..47507b6 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -127,9 +127,6 @@ MODULE_PARM_DESC(rx_xon_thresh_bytes, "RX fifo XON threshold");
  **************************************************************************
  */
 
-/* DMA address mask */
-#define FALCON_DMA_MASK DMA_BIT_MASK(46)
-
 /* TX DMA length mask (13-bit) */
 #define FALCON_TX_DMA_MASK (4096 - 1)
 
@@ -3148,7 +3145,7 @@ struct efx_nic_type falcon_a_nic_type = {
 	.buf_tbl_base = FR_AA_BUF_FULL_TBL_KER,
 	.evq_ptr_tbl_base = FR_AA_EVQ_PTR_TBL_KER,
 	.evq_rptr_tbl_base = FR_AA_EVQ_RPTR_KER,
-	.max_dma_mask = FALCON_DMA_MASK,
+	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
 	.tx_dma_mask = FALCON_TX_DMA_MASK,
 	.bug5391_mask = 0xf,
 	.rx_buffer_padding = 0x24,
@@ -3169,7 +3166,7 @@ struct efx_nic_type falcon_b_nic_type = {
 	.buf_tbl_base = FR_BZ_BUF_FULL_TBL,
 	.evq_ptr_tbl_base = FR_BZ_EVQ_PTR_TBL,
 	.evq_rptr_tbl_base = FR_BZ_EVQ_RPTR,
-	.max_dma_mask = FALCON_DMA_MASK,
+	.max_dma_mask = DMA_BIT_MASK(FSF_AZ_TX_KER_BUF_ADDR_WIDTH),
 	.tx_dma_mask = FALCON_TX_DMA_MASK,
 	.bug5391_mask = 0,
 	.rx_buffer_padding = 0,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


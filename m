From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/27] sfc: Move efx_xmit_done() declaration into correct
	stanza
Date: Fri, 23 Oct 2009 19:31:54 +0100
Message-ID: <1256322714.2785.35.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8806 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752899AbZJWSbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:31:52 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 20c8d62..ae76760 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -23,13 +23,13 @@
 extern netdev_tx_t efx_xmit(struct efx_nic *efx,
 				  struct efx_tx_queue *tx_queue,
 				  struct sk_buff *skb);
+extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 extern void efx_stop_queue(struct efx_nic *efx);
 extern void efx_wake_queue(struct efx_nic *efx);
 #define EFX_TXQ_SIZE 1024
 #define EFX_TXQ_MASK (EFX_TXQ_SIZE - 1)
 
 /* RX */
-extern void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index);
 extern void efx_rx_packet(struct efx_rx_queue *rx_queue, unsigned int index,
 			  unsigned int len, bool checksummed, bool discard);
 extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/17] sfc: Add necessary parentheses to macro definitions
 in net_driver.h
Date: Wed, 28 Apr 2010 20:29:50 +0100
Message-ID: <1272482990.2549.29.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12600 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab0D1T3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:29:53 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 70aea3a..bdea03c 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -926,8 +926,8 @@ struct efx_nic_type {
 
 /* Iterate over all used channels */
 #define efx_for_each_channel(_channel, _efx)				\
-	for (_channel = &_efx->channel[0];				\
-	     _channel < &_efx->channel[EFX_MAX_CHANNELS];		\
+	for (_channel = &((_efx)->channel[0]);				\
+	     _channel < &((_efx)->channel[EFX_MAX_CHANNELS]);		\
 	     _channel++)						\
 		if (!_channel->used_flags)				\
 			continue;					\
@@ -935,31 +935,31 @@ struct efx_nic_type {
 
 /* Iterate over all used TX queues */
 #define efx_for_each_tx_queue(_tx_queue, _efx)				\
-	for (_tx_queue = &_efx->tx_queue[0];				\
-	     _tx_queue < &_efx->tx_queue[EFX_TX_QUEUE_COUNT];		\
+	for (_tx_queue = &((_efx)->tx_queue[0]);			\
+	     _tx_queue < &((_efx)->tx_queue[EFX_TX_QUEUE_COUNT]);	\
 	     _tx_queue++)
 
 /* Iterate over all TX queues belonging to a channel */
 #define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
-	for (_tx_queue = &_channel->efx->tx_queue[0];			\
-	     _tx_queue < &_channel->efx->tx_queue[EFX_TX_QUEUE_COUNT];	\
+	for (_tx_queue = &((_channel)->efx->tx_queue[0]);		\
+	     _tx_queue < &((_channel)->efx->tx_queue[EFX_TX_QUEUE_COUNT]); \
 	     _tx_queue++)						\
-		if (_tx_queue->channel != _channel)			\
+		if (_tx_queue->channel != (_channel))			\
 			continue;					\
 		else
 
 /* Iterate over all used RX queues */
 #define efx_for_each_rx_queue(_rx_queue, _efx)				\
-	for (_rx_queue = &_efx->rx_queue[0];				\
-	     _rx_queue < &_efx->rx_queue[_efx->n_rx_queues];		\
+	for (_rx_queue = &((_efx)->rx_queue[0]);			\
+	     _rx_queue < &((_efx)->rx_queue[(_efx)->n_rx_queues]);	\
 	     _rx_queue++)
 
 /* Iterate over all RX queues belonging to a channel */
 #define efx_for_each_channel_rx_queue(_rx_queue, _channel)		\
-	for (_rx_queue = &_channel->efx->rx_queue[_channel->channel];	\
+	for (_rx_queue = &((_channel)->efx->rx_queue[(_channel)->channel]); \
 	     _rx_queue;							\
 	     _rx_queue = NULL)						\
-		if (_rx_queue->channel != _channel)			\
+		if (_rx_queue->channel != (_channel))			\
 			continue;					\
 		else
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


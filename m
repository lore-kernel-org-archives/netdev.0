From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/2] sfc: Remove unused field and comment on a
 previously removed field
Date: Tue, 21 Dec 2010 14:48:42 +0000
Message-ID: <1292942922.3256.3.camel@bwh-desktop>
References: <1292942817.3256.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59357 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab0LUOsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 09:48:46 -0500
In-Reply-To: <1292942817.3256.2.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 76f2fb1..294379f 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -179,7 +179,6 @@ struct efx_tx_queue {
 	struct efx_nic *efx ____cacheline_aligned_in_smp;
 	unsigned queue;
 	struct efx_channel *channel;
-	struct efx_nic *nic;
 	struct efx_tx_buffer *buffer;
 	struct efx_special_buffer txd;
 	unsigned int ptr_mask;
@@ -321,7 +320,6 @@ enum efx_rx_alloc_method {
  * @irq_moderation: IRQ moderation value (in hardware ticks)
  * @napi_dev: Net device used with NAPI
  * @napi_str: NAPI control structure
- * @reset_work: Scheduled reset work thread
  * @work_pending: Is work pending via NAPI?
  * @eventq: Event queue buffer
  * @eventq_mask: Event queue pointer mask
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


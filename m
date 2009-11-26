From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/16] sfc: Remove unused function efx_flush_queues()
Date: Thu, 26 Nov 2009 02:10:05 +0000
Message-ID: <1259201405.2806.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:31208 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbZKZCKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:10:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   13 -------------
 drivers/net/sfc/efx.h |    1 -
 2 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index dc85efa..4ebad61 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1237,19 +1237,6 @@ static void efx_remove_all(struct efx_nic *efx)
 	efx_remove_nic(efx);
 }
 
-/* A convinience function to safely flush all the queues */
-void efx_flush_queues(struct efx_nic *efx)
-{
-	EFX_ASSERT_RESET_SERIALISED(efx);
-
-	efx_stop_all(efx);
-
-	efx_fini_channels(efx);
-	efx_init_channels(efx);
-
-	efx_start_all(efx);
-}
-
 /**************************************************************************
  *
  * Interrupt moderation
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 3497b03..7acf821 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -56,7 +56,6 @@ extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay);
 
 /* Channels */
 extern void efx_process_channel_now(struct efx_channel *channel);
-extern void efx_flush_queues(struct efx_nic *efx);
 #define EFX_EVQ_SIZE 4096
 #define EFX_EVQ_MASK (EFX_EVQ_SIZE - 1)
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


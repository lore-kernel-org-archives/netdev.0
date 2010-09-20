From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 7/8] sfc: Set net_device::num_rx_queues once
 we know the correct value
Date: Mon, 20 Sep 2010 19:43:59 +0100
Message-ID: <1285008239.2282.110.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7288 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863Ab0ITSoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:44:02 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4a1c93f..48e2bf4 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1315,6 +1315,7 @@ static int efx_probe_nic(struct efx_nic *efx)
 
 	efx_set_channels(efx);
 	efx->net_dev->real_num_tx_queues = efx->n_tx_channels;
+	efx->net_dev->num_rx_queues = efx->n_rx_channels;
 
 	/* Initialise the interrupt moderation settings */
 	efx_init_irq_moderation(efx, tx_irq_mod_usec, rx_irq_mod_usec, true);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


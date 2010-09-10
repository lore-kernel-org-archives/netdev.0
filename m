From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 03/10] sfc: Remove declarations of functions
 that no longer exist
Date: Fri, 10 Sep 2010 17:41:12 +0100
Message-ID: <1284136872.2267.97.camel@achroite.uk.solarflarecom.com>
References: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25540 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755790Ab0IJQlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 12:41:19 -0400
In-Reply-To: <1284136817.2267.93.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 060dc95..d6b172b 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -81,8 +81,6 @@ extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
 extern void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs,
 				    int rx_usecs, bool rx_adaptive);
-extern int efx_request_power(struct efx_nic *efx, int mw, const char *name);
-extern void efx_hex_dump(const u8 *, unsigned int, const char *);
 
 /* Dummy PHY ops for PHY drivers */
 extern int efx_port_dummy_op_int(struct efx_nic *efx);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


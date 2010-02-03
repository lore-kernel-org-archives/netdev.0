From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/10] sfc: Remove declarations of nonexistent functions
Date: Wed, 03 Feb 2010 19:31:46 +0000
Message-ID: <1265225507.2116.8.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28113 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757494Ab0BCTbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:31:50 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index a615ac0..7eff0a6 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -79,8 +79,6 @@ extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
 
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
-extern void efx_suspend(struct efx_nic *efx);
-extern void efx_resume(struct efx_nic *efx);
 extern void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs,
 				    int rx_usecs, bool rx_adaptive);
 extern int efx_request_power(struct efx_nic *efx, int mw, const char *name);
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


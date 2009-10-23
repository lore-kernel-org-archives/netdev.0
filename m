From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/27] sfc: Remove declarations of nonexistent functions
Date: Fri, 23 Oct 2009 19:31:46 +0100
Message-ID: <1256322706.2785.33.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8794 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbZJWSbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:31:43 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index 8d232bf..4dd9657 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -91,11 +91,9 @@ extern void falcon_fini_interrupt(struct efx_nic *efx);
 
 /* Global Resources */
 extern int falcon_probe_nic(struct efx_nic *efx);
-extern int falcon_probe_resources(struct efx_nic *efx);
 extern int falcon_init_nic(struct efx_nic *efx);
 extern int falcon_flush_queues(struct efx_nic *efx);
 extern int falcon_reset_hw(struct efx_nic *efx, enum reset_type method);
-extern void falcon_remove_resources(struct efx_nic *efx);
 extern void falcon_remove_nic(struct efx_nic *efx);
 extern void falcon_update_nic_stats(struct efx_nic *efx);
 extern void falcon_set_multicast_hash(struct efx_nic *efx);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


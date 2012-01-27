From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 24/32] sfc: Remove obsolete function efx_dev_name()
Date: Fri, 27 Jan 2012 20:50:30 +0000
Message-ID: <1327697430.2503.31.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63760 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753982Ab2A0Uud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:50:33 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index a4cf8cb..310c50f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -791,15 +791,6 @@ static inline int efx_dev_registered(struct efx_nic *efx)
 	return efx->net_dev->reg_state == NETREG_REGISTERED;
 }
 
-/* Net device name, for inclusion in log messages if it has been registered.
- * Use efx->name not efx->net_dev->name so that races with (un)registration
- * are harmless.
- */
-static inline const char *efx_dev_name(struct efx_nic *efx)
-{
-	return efx_dev_registered(efx) ? efx->name : "";
-}
-
 static inline unsigned int efx_port_num(struct efx_nic *efx)
 {
 	return efx->net_dev->dev_id;
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

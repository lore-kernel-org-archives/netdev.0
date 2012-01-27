From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 28/32] sfc: Remove redundant 'rc' variable, always
 set to 0
Date: Fri, 27 Jan 2012 20:51:46 +0000
Message-ID: <1327697506.2503.35.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63826 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754115Ab2A0Uvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:51:49 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 8ecddd0..fce42f4 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1793,7 +1793,6 @@ static void efx_watchdog(struct net_device *net_dev)
 static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	int rc = 0;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
@@ -1816,7 +1815,7 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	efx_init_channels(efx);
 
 	efx_start_all(efx);
-	return rc;
+	return 0;
 }
 
 static int efx_set_mac_address(struct net_device *net_dev, void *data)
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

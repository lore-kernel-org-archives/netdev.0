From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/11] sfc: efx_ef10_filter_update_rx_scatter() can
 be static
Date: Sat, 21 Sep 2013 19:33:26 +0100
Message-ID: <1379788406.1681.36.camel@bwh-desktop.uk.level5networks.com>
References: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Fengguang Wu <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32572 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969Ab3IUSda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 14:33:30 -0400
In-Reply-To: <1379788283.1681.34.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <fengguang.wu@intel.com>

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 5f42313..6956bd2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2121,7 +2121,7 @@ out_unlock:
 	return rc;
 }
 
-void efx_ef10_filter_update_rx_scatter(struct efx_nic *efx)
+static void efx_ef10_filter_update_rx_scatter(struct efx_nic *efx)
 {
 	/* no need to do anything here on EF10 */
 }


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

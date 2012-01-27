From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 27/32] sfc: Minor formatting fixes
Date: Fri, 27 Jan 2012 20:51:29 +0000
Message-ID: <1327697489.2503.34.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63814 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754150Ab2A0Uvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:51:32 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index c8e1c8a..8ecddd0 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -798,16 +798,14 @@ void efx_link_status_changed(struct efx_nic *efx)
 	}
 
 	/* Status message for kernel log */
-	if (link_state->up) {
+	if (link_state->up)
 		netif_info(efx, link, efx->net_dev,
 			   "link up at %uMbps %s-duplex (MTU %d)%s\n",
 			   link_state->speed, link_state->fd ? "full" : "half",
 			   efx->net_dev->mtu,
 			   (efx->promiscuous ? " [PROMISC]" : ""));
-	} else {
+	else
 		netif_info(efx, link, efx->net_dev, "link down\n");
-	}
-
 }
 
 void efx_link_set_advertising(struct efx_nic *efx, u32 advertising)
@@ -1741,7 +1739,8 @@ static int efx_net_stop(struct net_device *net_dev)
 }
 
 /* Context: process, dev_base_lock or RTNL held, non-blocking. */
-static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_dev, struct rtnl_link_stats64 *stats)
+static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_dev,
+					       struct rtnl_link_stats64 *stats)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_mac_stats *mac_stats = &efx->mac_stats;
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

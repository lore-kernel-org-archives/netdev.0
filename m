From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 26/32] sfc: Use existing local variables instead of
 repeated indirect lookups
Date: Fri, 27 Jan 2012 20:51:10 +0000
Message-ID: <1327697470.2503.33.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63802 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751453Ab2A0UvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:51:13 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 4f412fe..c8e1c8a 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -364,7 +364,7 @@ static int efx_probe_eventq(struct efx_channel *channel)
 	struct efx_nic *efx = channel->efx;
 	unsigned long entries;
 
-	netif_dbg(channel->efx, probe, channel->efx->net_dev,
+	netif_dbg(efx, probe, efx->net_dev,
 		  "chan %d create event queue\n", channel->channel);
 
 	/* Build an event queue with room for one event per tx and rx buffer,
@@ -1971,7 +1971,7 @@ static int efx_register_netdev(struct efx_nic *efx)
 	}
 
 	/* Always start with carrier off; PHY events will detect the link */
-	netif_carrier_off(efx->net_dev);
+	netif_carrier_off(net_dev);
 
 	rtnl_unlock();
 
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

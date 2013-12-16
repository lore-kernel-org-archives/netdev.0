From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/11] sfc: remove unused 'enum efx_rx_alloc_method'
Date: Mon, 16 Dec 2013 21:34:07 +0000
Message-ID: <1387229647.1799.51.camel@bwh-desktop.uk.level5networks.com>
References: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Andrew Rybchenko" <Andrew.Rybchenko@oktetlabs.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8653 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017Ab3LPVeL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:34:11 -0500
In-Reply-To: <1387229350.1799.43.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index bc1ff36c03e6..af2b8c59a903 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -360,12 +360,6 @@ struct efx_rx_queue {
 	unsigned int slow_fill_count;
 };
 
-enum efx_rx_alloc_method {
-	RX_ALLOC_METHOD_AUTO = 0,
-	RX_ALLOC_METHOD_SKB = 1,
-	RX_ALLOC_METHOD_PAGE = 2,
-};
-
 enum efx_sync_events_state {
 	SYNC_EVENTS_DISABLED = 0,
 	SYNC_EVENTS_QUIESCENT,


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

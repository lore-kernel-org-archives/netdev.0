From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/16] sfc: Do not set net_device::trans_start in self-test
Date: Thu, 26 Nov 2009 02:12:31 +0000
Message-ID: <1259201551.2806.35.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31376 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455AbZKZCM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:12:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 4f4f287..1580607 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -435,7 +435,6 @@ static int efx_begin_loopback(struct efx_tx_queue *tx_queue)
 			kfree_skb(skb);
 			return -EPIPE;
 		}
-		efx->net_dev->trans_start = jiffies;
 	}
 
 	return 0;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


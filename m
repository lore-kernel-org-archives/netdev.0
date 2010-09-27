From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 12/17] mv643xx_eth: Use
 netif_set_real_num_{rx,tx}_queues()
Date: Mon, 27 Sep 2010 19:30:05 +0100
Message-ID: <1285612205.2263.310.camel@achroite.uk.solarflarecom.com>
References: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52015 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933295Ab0I0SaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 14:30:09 -0400
In-Reply-To: <1285611791.2263.287.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mv643xx_eth.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2d488ab..dd2b6a7 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2901,7 +2901,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	mp->dev = dev;
 
 	set_params(mp, pd);
-	dev->real_num_tx_queues = mp->txq_count;
+	netif_set_real_num_tx_queues(dev, mp->txq_count);
+	netif_set_real_num_rx_queues(dev, mp->rxq_count);
 
 	if (pd->phy_addr != MV643XX_ETH_PHY_NONE)
 		mp->phy = phy_scan(mp, pd->phy_addr);
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


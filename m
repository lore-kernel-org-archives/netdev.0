From: roopa@cumulusnetworks.com
Subject: [PATCH 3/3] rocker: set feature NETIF_F_HW_SWITCH_OFFLOAD
Date: Thu,  4 Dec 2014 18:26:41 -0800
Message-ID: <1417746401-8140-4-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38202 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933510AbaLEC0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 21:26:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch just sets the feature flag on rocker ports
---
 drivers/net/ethernet/rocker/rocker.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index fded127..3fe19b0 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4003,7 +4003,8 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 		       NAPI_POLL_WEIGHT);
 	rocker_carrier_init(rocker_port);
 
-	dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+	dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER |
+					 NETIF_F_HW_SWITCH_OFFLOAD;
 
 	err = register_netdev(dev);
 	if (err) {
-- 
1.7.10.4

From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 5/7] be2net: Remove TX Queue stop in close
Date: Mon, 7 Mar 2011 18:39:04 +0530
Message-ID: <0c6dc8ed-29a3-4dc5-985e-dc6cf004273e@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:52339 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751413Ab1CGNKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 08:10:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove TX Queue stop in close

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>
---
 drivers/net/benet/be_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 665a9b7..68b9d17 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2082,7 +2082,6 @@ static int be_close(struct net_device *netdev)
 
 	be_async_mcc_disable(adapter);
 
-	netif_stop_queue(netdev);
 	netif_carrier_off(netdev);
 	adapter->link_up = false;
 
-- 
1.6.0.2


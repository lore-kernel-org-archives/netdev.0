From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 1/4] be2net: Change the data type of the 'on die temperature' stat.
Date: Fri, 30 Sep 2011 22:53:35 +0530
Message-ID: <fb59059d-0453-468b-8b68-b76de7fae984@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:10146 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755678Ab1I3MAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 08:00:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was showing up as junk value on PPC /Big endian machines since
it was marked as a byte.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index c5f0516..894f1a9 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -245,7 +245,7 @@ struct be_rx_obj {
 };
 
 struct be_drv_stats {
-	u8 be_on_die_temperature;
+	u32 be_on_die_temperature;
 	u32 tx_events;
 	u32 eth_red_drops;
 	u32 rx_drops_no_pbuf;
-- 
1.5.6.1

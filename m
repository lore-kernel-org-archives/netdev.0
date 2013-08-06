From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/7] be2net: don't limit max MAC and VLAN counts
Date: Tue, 6 Aug 2013 09:27:17 +0530
Message-ID: <1375761441-22343-4-git-send-email-sathya.perla@emulex.com>
References: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:38614 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab3HFDyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:54:19 -0400
In-Reply-To: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

For SH-R and Lancer-R, use the FW supported values for Max unicast MACs,
Max VLANs and Max multicast MACs.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 834f77b..dc45e1a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2995,13 +2995,6 @@ static void be_get_resources(struct be_adapter *adapter)
 	}
 
 	if (profile_present) {
-		/* Sanity fixes for Lancer */
-		adapter->max_pmac_cnt = min_t(u16, adapter->max_pmac_cnt,
-					      BE_UC_PMAC_COUNT);
-		adapter->max_vlans = min_t(u16, adapter->max_vlans,
-					   BE_NUM_VLANS_SUPPORTED);
-		adapter->max_mcast_mac = min_t(u16, adapter->max_mcast_mac,
-					       BE_MAX_MC);
 		adapter->max_tx_queues = min_t(u16, adapter->max_tx_queues,
 					       MAX_TX_QS);
 		adapter->max_rss_queues = min_t(u16, adapter->max_rss_queues,
-- 
1.7.1

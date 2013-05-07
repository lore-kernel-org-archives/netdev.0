From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/8] qlcnic: Fix ethtool strings
Date: Tue, 7 May 2013 15:55:00 -0400
Message-ID: <1367956506-3290-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:28428
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752695Ab3EGUUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 16:20:05 -0400
In-Reply-To: <1367956506-3290-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Add missing information in ethtool statistics information array.
o Fix  the typo in the statistics information string.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 08efb46..6005b06 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -131,12 +131,13 @@ static const char qlcnic_83xx_rx_stats_strings[][ETH_GSTRING_LEN] = {
 	"ctx_lro_pkt_cnt",
 	"ctx_ip_csum_error",
 	"ctx_rx_pkts_wo_ctx",
-	"ctx_rx_pkts_dropped_wo_sts",
+	"ctx_rx_pkts_drop_wo_sds_on_card",
+	"ctx_rx_pkts_drop_wo_sds_on_host",
 	"ctx_rx_osized_pkts",
 	"ctx_rx_pkts_dropped_wo_rds",
 	"ctx_rx_unexpected_mcast_pkts",
 	"ctx_invalid_mac_address",
-	"ctx_rx_rds_ring_prim_attemoted",
+	"ctx_rx_rds_ring_prim_attempted",
 	"ctx_rx_rds_ring_prim_success",
 	"ctx_num_lro_flows_added",
 	"ctx_num_lro_flows_removed",
-- 
1.5.6

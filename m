From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net v2 2/8] qlcnic: Fix ethtool strings
Date: Thu, 9 May 2013 15:25:10 -0400
Message-ID: <1368127516-9943-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0185.outbound.messaging.microsoft.com ([213.199.154.185]:45986
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761Ab3EITt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 May 2013 15:49:59 -0400
In-Reply-To: <1368127516-9943-1-git-send-email-shahed.shaikh@qlogic.com>
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

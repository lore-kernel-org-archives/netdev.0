From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 3/7] qlcnic: Fix ethtool strings
Date: Fri, 26 Apr 2013 08:09:39 -0400
Message-ID: <1366978183-7282-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1366978183-7282-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.189] ([216.32.180.189]:30695 "EHLO
	co1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756350Ab3DZMf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 08:35:26 -0400
In-Reply-To: <1366978183-7282-1-git-send-email-shahed.shaikh@qlogic.com>
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
index 5641f8e..d169153 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -124,12 +124,13 @@ static const char qlcnic_83xx_rx_stats_strings[][ETH_GSTRING_LEN] = {
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

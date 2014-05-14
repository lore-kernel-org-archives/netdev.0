From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] ixgbe: add /* fallthrough */ comment to case statements
Date: Wed, 14 May 2014 01:54:21 -0700
Message-ID: <1400057663-4578-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46838 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753922AbaENIyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 04:54:39 -0400
In-Reply-To: <1400057663-4578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This semicomplex switch-case has various fallthrough portions, that were
not indicated by a /* fallthrough */ comment.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 0b9bfee..23e4e6a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2408,9 +2408,11 @@ static int ixgbe_get_rss_hash_opts(struct ixgbe_adapter *adapter,
 	switch (cmd->flow_type) {
 	case TCP_V4_FLOW:
 		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* fallthrough */
 	case UDP_V4_FLOW:
 		if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV4_UDP)
 			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* fallthrough */
 	case SCTP_V4_FLOW:
 	case AH_ESP_V4_FLOW:
 	case AH_V4_FLOW:
@@ -2420,9 +2422,11 @@ static int ixgbe_get_rss_hash_opts(struct ixgbe_adapter *adapter,
 		break;
 	case TCP_V6_FLOW:
 		cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* fallthrough */
 	case UDP_V6_FLOW:
 		if (adapter->flags2 & IXGBE_FLAG2_RSS_FIELD_IPV6_UDP)
 			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		/* fallthrough */
 	case SCTP_V6_FLOW:
 	case AH_ESP_V6_FLOW:
 	case AH_V6_FLOW:
-- 
1.9.0

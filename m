From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 13/15] ixgbe: rename LL_EXTENDED_STATS to use queue instead of q
Date: Wed, 31 Jul 2013 02:59:35 -0700
Message-ID: <1375264777-13595-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59620 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759350Ab3GaJ7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 05:59:50 -0400
In-Reply-To: <1375264777-13595-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch renames the stats introduced by the busy poll feature so that they
are more inline with the current statistics naming schemes.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index da1ea28..50c1e9b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1141,11 +1141,11 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			sprintf(p, "tx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
 #ifdef LL_EXTENDED_STATS
-			sprintf(p, "tx_q_%u_napi_yield", i);
+			sprintf(p, "tx_queue_%u_ll_napi_yield", i);
 			p += ETH_GSTRING_LEN;
-			sprintf(p, "tx_q_%u_misses", i);
+			sprintf(p, "tx_queue_%u_ll_misses", i);
 			p += ETH_GSTRING_LEN;
-			sprintf(p, "tx_q_%u_cleaned", i);
+			sprintf(p, "tx_queue_%u_ll_cleaned", i);
 			p += ETH_GSTRING_LEN;
 #endif /* LL_EXTENDED_STATS */
 		}
@@ -1155,11 +1155,11 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
 #ifdef LL_EXTENDED_STATS
-			sprintf(p, "rx_q_%u_ll_poll_yield", i);
+			sprintf(p, "rx_queue_%u_ll_poll_yield", i);
 			p += ETH_GSTRING_LEN;
-			sprintf(p, "rx_q_%u_misses", i);
+			sprintf(p, "rx_queue_%u_ll_misses", i);
 			p += ETH_GSTRING_LEN;
-			sprintf(p, "rx_q_%u_cleaned", i);
+			sprintf(p, "rx_queue_%u_ll_cleaned", i);
 			p += ETH_GSTRING_LEN;
 #endif /* LL_EXTENDED_STATS */
 		}
-- 
1.7.11.7

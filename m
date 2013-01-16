From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] e1000e: cleanup redundant statistics counter
Date: Wed, 16 Jan 2013 01:10:22 -0800
Message-ID: <1358327427-3146-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:50334 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932503Ab3APJKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 04:10:49 -0500
In-Reply-To: <1358327427-3146-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

rx_long_byte_count can be removed since it is duplicated in rx_bytes

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index f95bc6e..2225603 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -98,7 +98,6 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	E1000_STAT("rx_flow_control_xoff", stats.xoffrxc),
 	E1000_STAT("tx_flow_control_xon", stats.xontxc),
 	E1000_STAT("tx_flow_control_xoff", stats.xofftxc),
-	E1000_STAT("rx_long_byte_count", stats.gorc),
 	E1000_STAT("rx_csum_offload_good", hw_csum_good),
 	E1000_STAT("rx_csum_offload_errors", hw_csum_err),
 	E1000_STAT("rx_header_split", rx_hdr_split),
-- 
1.7.11.7

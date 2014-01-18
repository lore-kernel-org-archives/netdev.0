From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 4/7] ixgbevf: add tx counters
Date: Fri, 17 Jan 2014 18:30:02 -0800
Message-ID: <1390012205-21995-5-git-send-email-aaron.f.brown@intel.com>
References: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230AbaARCaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 21:30:13 -0500
In-Reply-To: <1390012205-21995-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds counters for tx_restart_queue and tx_timeout_count.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index b48df78..f68b78c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -77,6 +77,8 @@ static const struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"tx_bytes", IXGBEVF_STAT(stats.vfgotc, stats.base_vfgotc,
 				  stats.saved_reset_vfgotc)},
 	{"tx_busy", IXGBEVF_ZSTAT(tx_busy)},
+	{"tx_restart_queue", IXGBEVF_ZSTAT(restart_queue)},
+	{"tx_timeout_count", IXGBEVF_ZSTAT(tx_timeout_count)},
 	{"multicast", IXGBEVF_STAT(stats.vfmprc, stats.base_vfmprc,
 				   stats.saved_reset_vfmprc)},
 	{"rx_csum_offload_errors", IXGBEVF_ZSTAT(hw_csum_rx_error)},
-- 
1.8.5.GIT

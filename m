From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 21/25] fm10k: renamed mbx_tx_dropped to mbx_tx_oversized
Date: Tue, 14 Apr 2015 16:51:07 -0700
Message-ID: <1429055471-401-22-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754971AbbDNXv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:26 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The use of dropped doesn't really mean dropped mailbox messages, but
rather specifically messages which were too large to fit in the remote
Rx FIFO. Rename the stat to more clearly indicate what it means.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 45e504f..4b9d9f8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -77,7 +77,7 @@ static const struct fm10k_stats fm10k_gstrings_global_stats[] = {
 	FM10K_STAT("mac_rules_avail", hw.swapi.mac.avail),
 
 	FM10K_STAT("mbx_tx_busy", hw.mbx.tx_busy),
-	FM10K_STAT("mbx_tx_dropped", hw.mbx.tx_dropped),
+	FM10K_STAT("mbx_tx_oversized", hw.mbx.tx_dropped),
 	FM10K_STAT("mbx_tx_messages", hw.mbx.tx_messages),
 	FM10K_STAT("mbx_tx_dwords", hw.mbx.tx_dwords),
 	FM10K_STAT("mbx_rx_messages", hw.mbx.rx_messages),
-- 
1.9.3

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/25] fm10k: expose tx_timeout_count as an ethtool stat
Date: Tue, 14 Apr 2015 16:50:59 -0700
Message-ID: <1429055471-401-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jacob Keller <jacob.e.keller@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51346 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754105AbbDNXvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:24 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Named it tx_hang_count to differentiate it from tx_hwtstamp_timeout.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 4687f37..45e504f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -84,6 +84,8 @@ static const struct fm10k_stats fm10k_gstrings_global_stats[] = {
 	FM10K_STAT("mbx_rx_dwords", hw.mbx.rx_dwords),
 	FM10K_STAT("mbx_rx_parse_err", hw.mbx.rx_parse_err),
 
+	FM10K_STAT("tx_hang_count", tx_timeout_count),
+
 	FM10K_STAT("tx_hwtstamp_timeouts", tx_hwtstamp_timeouts),
 };
 
-- 
1.9.3

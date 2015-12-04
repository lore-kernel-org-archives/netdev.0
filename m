From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] fm10k: rename mbx_tx_oversized statistic to mbx_tx_dropped
Date: Thu,  3 Dec 2015 16:29:46 -0800
Message-ID: <1449188994-64940-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22000 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754320AbbLDA36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:58 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Originally this statistic was renamed because the method of dropping was
called "drop_oversized_messages", but this logic has changed much, and
this counter does actually represent messages which we failed to
transmit for a number of reasons. Rename the counter back to tx_dropped
since this is when it will increment, and it is less confusing.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 7c01561..fd29145 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -111,7 +111,7 @@ static const struct fm10k_stats fm10k_gstrings_pf_stats[] = {
 
 static const struct fm10k_stats fm10k_gstrings_mbx_stats[] = {
 	FM10K_MBX_STAT("mbx_tx_busy", tx_busy),
-	FM10K_MBX_STAT("mbx_tx_oversized", tx_dropped),
+	FM10K_MBX_STAT("mbx_tx_dropped", tx_dropped),
 	FM10K_MBX_STAT("mbx_tx_messages", tx_messages),
 	FM10K_MBX_STAT("mbx_tx_dwords", tx_dwords),
 	FM10K_MBX_STAT("mbx_tx_mbmem_pulled", tx_mbmem_pulled),
-- 
2.5.0

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/14] i40e: add RX to port CRC errors label
Date: Wed, 26 Aug 2015 15:49:21 -0700
Message-ID: <1440629373-21287-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34139 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562AbbHZWtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 18:49:36 -0400
In-Reply-To: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The port.crc_errors is really an RX counter, so let's mark it as such.

Change-ID: I179afd3f8a95d45229bb4163a6aeb01f0d2d250b
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 83d41c2..d6c7eb7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -114,7 +114,7 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("tx_errors", stats.eth.tx_errors),
 	I40E_PF_STAT("rx_dropped", stats.eth.rx_discards),
 	I40E_PF_STAT("tx_dropped_link_down", stats.tx_dropped_link_down),
-	I40E_PF_STAT("crc_errors", stats.crc_errors),
+	I40E_PF_STAT("rx_crc_errors", stats.crc_errors),
 	I40E_PF_STAT("illegal_bytes", stats.illegal_bytes),
 	I40E_PF_STAT("mac_local_faults", stats.mac_local_faults),
 	I40E_PF_STAT("mac_remote_faults", stats.mac_remote_faults),
-- 
2.4.3

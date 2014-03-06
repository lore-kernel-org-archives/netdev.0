From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e: count timeout events
Date: Wed,  5 Mar 2014 20:21:39 -0800
Message-ID: <1394079704-1108-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49472 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753178AbaCFEVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:21:53 -0500
In-Reply-To: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The ethtool -S statistics should have a counter for
tx timeouts in order to better help inform the masses.

Change-ID: Ice4b20ed4a151509f366719ab105be49c9e7b2b4
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 8d46c6e..d34ff31 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -87,6 +87,7 @@ static struct i40e_stats i40e_gstrings_stats[] = {
 	I40E_PF_STAT("illegal_bytes", stats.illegal_bytes),
 	I40E_PF_STAT("mac_local_faults", stats.mac_local_faults),
 	I40E_PF_STAT("mac_remote_faults", stats.mac_remote_faults),
+	I40E_PF_STAT("tx_timeout", tx_timeout_count),
 	I40E_PF_STAT("rx_length_errors", stats.rx_length_errors),
 	I40E_PF_STAT("link_xon_rx", stats.link_xon_rx),
 	I40E_PF_STAT("link_xoff_rx", stats.link_xoff_rx),
-- 
1.8.3.1

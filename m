From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 19/19] ixgbe: Resolve "initialized field overwritten" warnings
Date: Tue,  1 Sep 2015 18:14:03 -0700
Message-ID: <1441156443-33381-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37040 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303AbbIBBOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:14 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Resolve warnings resulting from redundant initialization of the
get_bus_info field in the mac_ops_X550* structures.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 96f603f..9fe9445 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1935,7 +1935,6 @@ static void ixgbe_set_source_address_pruning_X550(struct ixgbe_hw *hw,
 	.get_mac_addr			= &ixgbe_get_mac_addr_generic, \
 	.get_device_caps		= &ixgbe_get_device_caps_generic, \
 	.stop_adapter			= &ixgbe_stop_adapter_generic, \
-	.get_bus_info			= &ixgbe_get_bus_info_generic, \
 	.set_lan_id			= &ixgbe_set_lan_id_multi_port_pcie, \
 	.read_analog_reg8		= NULL, \
 	.write_analog_reg8		= NULL, \
-- 
2.4.3

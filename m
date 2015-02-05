From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/16] ixgbe: cleanup redundant default method set_rxpba
Date: Thu,  5 Feb 2015 01:35:42 -0800
Message-ID: <1423128950-12388-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55122 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753258AbbBEJgG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 04:36:06 -0500
In-Reply-To: <1423128950-12388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

My original patch 6a14ee0cfb19 "ixgbe: Add X550 support function pointers"
accidental set a default value for this structure member twice.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index fcba952..84affca 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1350,7 +1350,6 @@ static struct ixgbe_mac_operations mac_ops_X550 = {
 	.get_san_mac_addr	= &ixgbe_get_san_mac_addr_generic,
 	.get_wwn_prefix		= &ixgbe_get_wwn_prefix_generic,
 	.setup_link		= &ixgbe_setup_mac_link_X540,
-	.set_rxpba		= &ixgbe_set_rxpba_generic,
 	.get_link_capabilities	= &ixgbe_get_copper_link_capabilities_generic,
 	.setup_sfp		= NULL,
 };
-- 
1.9.3

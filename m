From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/19] ixgbe: Remove unused PCI bus types
Date: Tue,  1 Sep 2015 18:13:54 -0700
Message-ID: <1441156443-33381-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37040 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754591AbbIBBOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:11 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The ixgbe never has as very doubtfully ever will support either
PCI or PCI-X devices.  So remove the unused types from the
ixgbe_bus_type.  Thanks to Alex Duyck for suggesting this.

Signed-off-by: Donald C Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 37df15f..1c5a5b3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3064,8 +3064,6 @@ enum ixgbe_smart_speed {
 /* PCI bus types */
 enum ixgbe_bus_type {
 	ixgbe_bus_type_unknown = 0,
-	ixgbe_bus_type_pci,
-	ixgbe_bus_type_pcix,
 	ixgbe_bus_type_pci_express,
 	ixgbe_bus_type_internal,
 	ixgbe_bus_type_reserved
-- 
2.4.3

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40evf: Remove unused defines
Date: Wed, 21 May 2014 05:01:00 -0700
Message-ID: <1400673673-31626-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20362 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751882AbaEUMBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 08:01:23 -0400
In-Reply-To: <1400673673-31626-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Remove the defines for PCI bus info that are never used.

Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 51a6dee..a1055b4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -101,15 +101,6 @@ enum i40e_debug_mask {
 	I40E_DEBUG_ALL			= 0xFFFFFFFF
 };
 
-/* PCI Bus Info */
-#define I40E_PCI_LINK_WIDTH_1		0x10
-#define I40E_PCI_LINK_WIDTH_2		0x20
-#define I40E_PCI_LINK_WIDTH_4		0x40
-#define I40E_PCI_LINK_WIDTH_8		0x80
-#define I40E_PCI_LINK_SPEED_2500	0x1
-#define I40E_PCI_LINK_SPEED_5000	0x2
-#define I40E_PCI_LINK_SPEED_8000	0x3
-
 /* These are structs for managing the hardware information and the operations.
  * The structures of function pointers are filled out at init time when we
  * know for sure exactly which hardware we're working with.  This gives us the
-- 
1.9.0

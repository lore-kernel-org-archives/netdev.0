From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/14] i40e: Remove FPK HyperV VF device ID
Date: Fri,  3 Feb 2017 18:56:42 -0800
Message-ID: <20170204025645.174793-12-jeffrey.t.kirsher@intel.com>
References: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Cc: Jayaprakash Shanmugam <jayaprakash.shanmugam@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14635 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753530AbdBDC4u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 21:56:50 -0500
In-Reply-To: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jayaprakash Shanmugam <jayaprakash.shanmugam@intel.com>

Requirement for VFs to use the VMBus has been removed that's why
removing Hyper-V VF device ID.

Change-ID: I84f0964f443ee0db3e5e444b5ace996eb71b8280
Signed-off-by: Jayaprakash Shanmugam <jayaprakash.shanmugam@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_common.c | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_devids.h | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index aa63b7f..b5a59dd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -64,7 +64,6 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 			hw->mac.type = I40E_MAC_X722;
 			break;
 		case I40E_DEV_ID_X722_VF:
-		case I40E_DEV_ID_X722_VF_HV:
 			hw->mac.type = I40E_MAC_X722_VF;
 			break;
 		case I40E_DEV_ID_VF:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_devids.h b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
index 21dcaee..d76393c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_devids.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_devids.h
@@ -48,7 +48,6 @@
 #define I40E_DEV_ID_10G_BASE_T_X722	0x37D2
 #define I40E_DEV_ID_SFP_I_X722		0x37D3
 #define I40E_DEV_ID_X722_VF		0x37CD
-#define I40E_DEV_ID_X722_VF_HV		0x37D9
 
 #define i40e_is_40G_device(d)		((d) == I40E_DEV_ID_QSFP_A  || \
 					 (d) == I40E_DEV_ID_QSFP_B  || \
-- 
2.10.2

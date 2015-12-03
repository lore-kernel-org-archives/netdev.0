From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40evf: use correct types
Date: Thu,  3 Dec 2015 05:25:53 -0800
Message-ID: <1449149160-105219-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:6976 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759239AbbLCN0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:05 -0500
In-Reply-To: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Don't use uint32_t type the kernel. Use u32 instead. No functional
change.

Change-ID: I77bbf3b6464edaef747c7104b43534032a4dba63
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 82c9adf..2577757 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -259,7 +259,7 @@ static void i40evf_fire_sw_int(struct i40evf_adapter *adapter, u32 mask)
 {
 	struct i40e_hw *hw = &adapter->hw;
 	int i;
-	uint32_t dyn_ctl;
+	u32 dyn_ctl;
 
 	if (mask & 1) {
 		dyn_ctl = rd32(hw, I40E_VFINT_DYN_CTL01);
-- 
2.5.0

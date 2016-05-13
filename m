From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] igb: make igb_update_pf_vlvf static
Date: Fri, 13 May 2016 16:43:45 -0700
Message-ID: <1463183035-31888-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:49411 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119AbcEMXn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 19:43:59 -0400
In-Reply-To: <1463183035-31888-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0191c5f..cab3069 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6027,7 +6027,7 @@ static int igb_find_vlvf_entry(struct e1000_hw *hw, u32 vlan)
 	return idx;
 }
 
-void igb_update_pf_vlvf(struct igb_adapter *adapter, u32 vid)
+static void igb_update_pf_vlvf(struct igb_adapter *adapter, u32 vid)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 bits, pf_id;
-- 
2.5.5

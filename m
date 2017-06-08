From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/2] igb: make a few local functions static
Date: Wed,  7 Jun 2017 22:32:36 -0700
Message-ID: <20170608053237.73040-2-jeffrey.t.kirsher@intel.com>
References: <20170608053237.73040-1-jeffrey.t.kirsher@intel.com>
Cc: Colin Ian King <colin.king@canonical.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30535 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750788AbdFHFcm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Jun 2017 01:32:42 -0400
In-Reply-To: <20170608053237.73040-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Clean up a few sparse warnings, these following
functions can be made static:

drivers/net/ethernet/intel/igb/igb_main.c: warning: symbol
  'igb_add_mac_filter' was not declared. Should it be static?
drivers/net/ethernet/intel/igb/igb_main.c: warning: symbol
  'igb_del_mac_filter' was not declared. Should it be static?
drivers/net/ethernet/intel/igb/igb_main.c: warning: symbol
  'igb_set_vf_mac_filter' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 7e433344a13c..ec62410b035a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6469,8 +6469,8 @@ static void igb_set_default_mac_filter(struct igb_adapter *adapter)
 	igb_rar_set_index(adapter, 0);
 }
 
-int igb_add_mac_filter(struct igb_adapter *adapter, const u8 *addr,
-		       const u8 queue)
+static int igb_add_mac_filter(struct igb_adapter *adapter, const u8 *addr,
+			      const u8 queue)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	int rar_entries = hw->mac.rar_entry_count -
@@ -6499,8 +6499,8 @@ int igb_add_mac_filter(struct igb_adapter *adapter, const u8 *addr,
 	return -ENOSPC;
 }
 
-int igb_del_mac_filter(struct igb_adapter *adapter, const u8 *addr,
-		       const u8 queue)
+static int igb_del_mac_filter(struct igb_adapter *adapter, const u8 *addr,
+			      const u8 queue)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	int rar_entries = hw->mac.rar_entry_count -
@@ -6552,8 +6552,8 @@ static int igb_uc_unsync(struct net_device *netdev, const unsigned char *addr)
 	return 0;
 }
 
-int igb_set_vf_mac_filter(struct igb_adapter *adapter, const int vf,
-			  const u32 info, const u8 *addr)
+static int igb_set_vf_mac_filter(struct igb_adapter *adapter, const int vf,
+				 const u32 info, const u8 *addr)
 {
 	struct pci_dev *pdev = adapter->pdev;
 	struct vf_data_storage *vf_data = &adapter->vf_data[vf];
-- 
2.12.2

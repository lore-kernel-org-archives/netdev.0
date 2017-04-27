From: Colin King <colin.king@canonical.com>
Subject: [PATCH] igb: make a few local functions static
Date: Thu, 27 Apr 2017 18:59:11 +0100
Message-ID: <20170427175911.15477-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

clean up a few sparse warnings, these following
functions can be made static:

drivers/net/ethernet/intel/igb/igb_main.c: warning: symbol
  'igb_add_mac_filter' was not declared. Should it be static?
drivers/net/ethernet/intel/igb/igb_main.c: warning: symbol
  'igb_del_mac_filter' was not declared. Should it be static?
drivers/net/ethernet/intel/igb/igb_main.c: warning: symbol
  'igb_set_vf_mac_filter' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1cf74aa4ebd9..b0021819b9d0 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6457,8 +6457,8 @@ static void igb_set_default_mac_filter(struct igb_adapter *adapter)
 	igb_rar_set_index(adapter, 0);
 }
 
-int igb_add_mac_filter(struct igb_adapter *adapter, const u8 *addr,
-		       const u8 queue)
+static int igb_add_mac_filter(struct igb_adapter *adapter, const u8 *addr,
+			      const u8 queue)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	int rar_entries = hw->mac.rar_entry_count -
@@ -6487,8 +6487,8 @@ int igb_add_mac_filter(struct igb_adapter *adapter, const u8 *addr,
 	return -ENOSPC;
 }
 
-int igb_del_mac_filter(struct igb_adapter *adapter, const u8 *addr,
-		       const u8 queue)
+static int igb_del_mac_filter(struct igb_adapter *adapter, const u8 *addr,
+			      const u8 queue)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	int rar_entries = hw->mac.rar_entry_count -
@@ -6540,8 +6540,8 @@ static int igb_uc_unsync(struct net_device *netdev, const unsigned char *addr)
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
2.11.0


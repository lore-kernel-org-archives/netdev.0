From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e/i40evf: Clean up some formatting and other things
Date: Thu,  5 Mar 2015 08:46:28 -0800
Message-ID: <1425573992-30955-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Neerav Parikh <neerav.parikh@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8728 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756049AbbCEQqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:39 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Fix some double blank lines and un-split a function declaration that all
fits on one line. Also make i40e_get_priv_flags static.

Change-ID: I11b5d25d1153a06b286d0d2f5d916d7727c58e4a
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 1 -
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        | 2 --
 drivers/net/ethernet/intel/i40e/i40e_fcoe.h        | 1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_common.c    | 1 -
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h | 3 +--
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 1 -
 8 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 99af788..10f9451 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -541,7 +541,6 @@ struct i40e_rx_ptype_decoded i40e_ptype_lookup[] = {
 	I40E_PTT_UNUSED_ENTRY(255)
 };
 
-
 /**
  * i40e_init_shared_code - Initialize the shared code
  * @hw: pointer to hardware structure
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 764305e..e045de1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2380,7 +2380,7 @@ static int i40e_set_channels(struct net_device *dev,
  *
  * Returns a u32 bitmap of flags.
  **/
-u32 i40e_get_priv_flags(struct net_device *dev)
+static u32 i40e_get_priv_flags(struct net_device *dev)
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
index 05d883e..0357b31 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.c
@@ -24,7 +24,6 @@
  *
  ******************************************************************************/
 
-
 #include <linux/if_ether.h>
 #include <scsi/scsi_cmnd.h>
 #include <scsi/scsi_device.h>
@@ -1447,7 +1446,6 @@ static int i40e_fcoe_set_features(struct net_device *netdev,
 	return 0;
 }
 
-
 static const struct net_device_ops i40e_fcoe_netdev_ops = {
 	.ndo_open		= i40e_open,
 	.ndo_stop		= i40e_close,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_fcoe.h b/drivers/net/ethernet/intel/i40e/i40e_fcoe.h
index 21e0f58..0d49e2d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_fcoe.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_fcoe.h
@@ -37,7 +37,6 @@
 #define I40E_FILTER_CONTEXT_DESC(R, i)  \
 	(&(((struct i40e_fcoe_filter_context_desc *)((R)->desc))[i]))
 
-
 /* receive queue descriptor filter status for FCoE */
 #define I40E_RX_DESC_FLTSTAT_FCMASK	0x3
 #define I40E_RX_DESC_FLTSTAT_NOMTCH	0x0	/* no ddp context match */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a287cc8..02b57c3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9586,7 +9586,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_info(&pdev->dev,
 			 "The driver for the device detected an older version of the NVM image than expected. Please update the NVM image.\n");
 
-
 	i40e_verify_eeprom(pf);
 
 	/* Rev 0 hardware was never productized */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 50b0ee5..0335b3f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -542,7 +542,6 @@ struct i40e_rx_ptype_decoded i40evf_ptype_lookup[] = {
 	I40E_PTT_UNUSED_ENTRY(255)
 };
 
-
 /**
  * i40e_aq_send_msg_to_pf
  * @hw: pointer to the hardware structure
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
index 9173834..58e37a4 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -59,8 +59,7 @@ void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask,
 void i40e_idle_aq(struct i40e_hw *hw);
 void i40evf_resume_aq(struct i40e_hw *hw);
 bool i40evf_check_asq_alive(struct i40e_hw *hw);
-i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
-					     bool unloading);
+i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw, bool unloading);
 
 i40e_status i40e_set_mac_type(struct i40e_hw *hw);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 681a5d4..b68b731 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -29,7 +29,6 @@
 
 #include <linux/uaccess.h>
 
-
 struct i40evf_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int stat_offset;
-- 
1.9.3

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 13/25] ixgb: clean up un-necessary declarations
Date: Tue, 08 Jul 2008 15:52:08 -0700
Message-ID: <20080708225208.6925.71998.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53842 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753088AbYGHWwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:09 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |   27 +++++++++------------------
 1 files changed, 9 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 4e422c4..fc2cf0e 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -61,7 +61,7 @@ static struct pci_device_id ixgb_pci_tbl[] = {
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,  
+	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 
 	/* required last entry */
@@ -71,16 +71,6 @@ static struct pci_device_id ixgb_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci, ixgb_pci_tbl);
 
 /* Local Function Prototypes */
-
-int ixgb_up(struct ixgb_adapter *adapter);
-void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog);
-void ixgb_reset(struct ixgb_adapter *adapter);
-int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
-int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
-void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
-void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
-void ixgb_update_stats(struct ixgb_adapter *adapter);
-
 static int ixgb_init_module(void);
 static void ixgb_exit_module(void);
 static int ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
@@ -103,17 +93,18 @@ static irqreturn_t ixgb_intr(int irq, void *data);
 static bool ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
 
 #ifdef CONFIG_IXGB_NAPI
-static int ixgb_clean(struct napi_struct *napi, int budget);
-static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
-			      int *work_done, int work_to_do);
+static int ixgb_clean(struct napi_struct *, int);
+static bool ixgb_clean_rx_irq(struct ixgb_adapter *, int *, int);
 #else
-static bool ixgb_clean_rx_irq(struct ixgb_adapter *adapter);
+static bool ixgb_clean_rx_irq(struct ixgb_adapter *);
 #endif
-static void ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter);
+static void ixgb_alloc_rx_buffers(struct ixgb_adapter *);
+
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct work_struct *work);
+
 static void ixgb_vlan_rx_register(struct net_device *netdev,
-				  struct vlan_group *grp);
+                                  struct vlan_group *grp);
 static void ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
@@ -124,7 +115,7 @@ static void ixgb_netpoll(struct net_device *dev);
 #endif
 
 static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
-	                     enum pci_channel_state state);
+                             enum pci_channel_state state);
 static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev);
 static void ixgb_io_resume (struct pci_dev *pdev);
 


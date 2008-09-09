From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 02/24] ixgbe: fix dca defines to not have spaces
Date: Mon, 08 Sep 2008 21:47:37 -0700
Message-ID: <20080909044737.18904.92122.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.248]:59329 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723AbYIIErl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 00:47:41 -0400
Received: by hs-out-0708.google.com with SMTP id 4so428996hsl.5
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2008 21:47:39 -0700 (PDT)
In-Reply-To: <20080909044734.18904.93208.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c67211c..9048195 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -80,7 +80,7 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 };
 MODULE_DEVICE_TABLE(pci, ixgbe_pci_tbl);
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *, unsigned long event,
 			    void *p);
 static struct notifier_block dca_notifier = {
@@ -309,7 +309,7 @@ done_cleaning:
 	return (total_packets ? true : false);
 }
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 				struct ixgbe_ring *rx_ring)
 {
@@ -934,7 +934,7 @@ static irqreturn_t ixgbe_msix_clean_tx(int irq, void *data)
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
 		tx_ring = &(adapter->tx_ring[r_idx]);
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_tx_dca(adapter, tx_ring);
 #endif
@@ -999,7 +999,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	rx_ring = &(adapter->rx_ring[r_idx]);
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 		ixgbe_update_rx_dca(adapter, rx_ring);
 #endif
@@ -2102,7 +2102,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&adapter->pdev->dev);
@@ -2114,7 +2114,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	/* since we reset the hardware DCA settings were cleared */
 	if (dca_add_requester(&adapter->pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
@@ -2178,7 +2178,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	int tx_cleaned = 0, work_done = 0;
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		ixgbe_update_tx_dca(adapter, adapter->tx_ring);
 		ixgbe_update_rx_dca(adapter, adapter->rx_ring);
@@ -3754,7 +3754,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_register;
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 		/* always use CB2 mode, difference is masked
@@ -3804,7 +3804,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
 		dca_remove_requester(&pdev->dev);
@@ -3937,7 +3937,7 @@ static int __init ixgbe_init_module(void)
 
 	printk(KERN_INFO "%s: %s\n", ixgbe_driver_name, ixgbe_copyright);
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	dca_register_notify(&dca_notifier);
 
 #endif
@@ -3954,13 +3954,13 @@ module_init(ixgbe_init_module);
  **/
 static void __exit ixgbe_exit_module(void)
 {
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&ixgbe_driver);
 }
 
-#if defined(CONFIG_DCA) || defined (CONFIG_DCA_MODULE)
+#if defined(CONFIG_DCA) || defined(CONFIG_DCA_MODULE)
 static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
 			    void *p)
 {


From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 9/9] ixgb: White space/driver version number update
Date: Thu, 6 Jan 2005 17:26:32 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061556250.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-01-05 17:13:27.000000000 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-01-05 17:13:29.000000000 -0800
@@ -35,7 +35,7 @@ char ixgb_driver_string[] = "Intel(R) PR
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char ixgb_driver_version[] = "1.0.82-k2"DRIVERNAPI;
+char ixgb_driver_version[] = "1.0.87-k2"DRIVERNAPI;
 char ixgb_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
@@ -62,8 +62,6 @@ MODULE_DEVICE_TABLE(pci, ixgb_pci_tbl);
 
 /* Local Function Prototypes */
 
-static inline void ixgb_irq_disable(struct ixgb_adapter *adapter);
-static inline void ixgb_irq_enable(struct ixgb_adapter *adapter);
 int ixgb_up(struct ixgb_adapter *adapter);
 void ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog);
 void ixgb_reset(struct ixgb_adapter *adapter);
@@ -93,9 +94,6 @@ static void ixgb_clean_rx_ring(struct ix
 static int ixgb_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t ixgb_intr(int irq, void *data, struct pt_regs *regs);
 static boolean_t ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
-static inline void ixgb_rx_checksum(struct ixgb_adapter *adapter,
-				    struct ixgb_rx_desc *rx_desc,
-				    struct sk_buff *skb);
 #ifdef CONFIG_IXGB_NAPI
 static int ixgb_clean(struct net_device *netdev, int *budget);
 static boolean_t ixgb_clean_rx_irq(struct ixgb_adapter *adapter,
@@ -107,14 +94,12 @@ 
 void set_ethtool_ops(struct net_device *netdev);
 static void ixgb_tx_timeout(struct net_device *dev);
 static void ixgb_tx_timeout_task(struct net_device *dev);
-static void ixgb_vlan_rx_register(struct net_device *netdev,
-				  struct vlan_group *grp);
+static void ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
 static void ixgb_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
 static void ixgb_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
 
-static int ixgb_notify_reboot(struct notifier_block *, unsigned long event,
-			      void *ptr);
+static int ixgb_notify_reboot(struct notifier_block *, unsigned long event, void *ptr);
 static int ixgb_suspend(struct pci_dev *pdev, uint32_t state);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -198,7 +191,8 @@ module_exit(ixgb_exit_module);
  * @adapter: board private structure
  **/
 
-static inline void ixgb_irq_disable(struct ixgb_adapter *adapter)
+static inline void
+ixgb_irq_disable(struct ixgb_adapter *adapter)
 {
 	atomic_inc(&adapter->irq_sem);
 	IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
@@ -211,7 +221,8 @@ static inline void ixgb_irq_disable(stru
  * @adapter: board private structure
  **/
 
-static inline void ixgb_irq_enable(struct ixgb_adapter *adapter)
+static inline void
+ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
 	if (atomic_dec_and_test(&adapter->irq_sem)) {
 		IXGB_WRITE_REG(&adapter->hw, IMS,
@@ -706,11 +701,11 @@ ixgb_configure_tx(struct ixgb_adapter *a
 
 	/* don't set up txdctl, it induces performance problems if
 	 * configured incorrectly
-	 txdctl  = TXDCTL_PTHRESH_DEFAULT; // prefetch txds below this threshold
-	 txdctl |= (TXDCTL_HTHRESH_DEFAULT // only prefetch if there are this many ready
-	 << IXGB_TXDCTL_HTHRESH_SHIFT);
-	 IXGB_WRITE_REG (hw, TXDCTL, txdctl);
-	 */
+	txdctl  = TXDCTL_PTHRESH_DEFAULT; // prefetch txds below this threshold
+	txdctl |= (TXDCTL_HTHRESH_DEFAULT // only prefetch if there are this many ready
+			   << IXGB_TXDCTL_HTHRESH_SHIFT);
+	IXGB_WRITE_REG (hw, TXDCTL, txdctl);
+	*/
 
 	/* Set the Tx Interrupt Delay register */
 
@@ -1634,7 +1629,7 @@ ixgb_intr(int irq, void *data, struct pt
 		*/
 
 		atomic_inc(&adapter->irq_sem);
-		IXGB_WRITE_REG(hw, IMC, ~0);
+		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 		__netif_rx_schedule(netdev);
 	}
 #else
@@ -1754,8 +1795,8 @@ ixgb_clean_tx_irq(struct ixgb_adapter *a
 	/* Ignore Checksum bit is set OR
 	 * TCP Checksum has not been calculated
 	 */
-	if ((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
-	    (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
+	if((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
+	   (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
 		skb->ip_summed = CHECKSUM_NONE;
 		return;
 	}
@@ -1762,7 +1795,7 @@ 
 
 	/* At this point we know the hardware did the TCP checksum */
 	/* now look at the TCP checksum error bit */
-	if (rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
+	if(rx_desc->errors & IXGB_RX_DESC_ERRORS_TCPE) {
 		/* let the stack verify checksum errors */
 		skb->ip_summed = CHECKSUM_NONE;
 		adapter->hw_csum_rx_error++;

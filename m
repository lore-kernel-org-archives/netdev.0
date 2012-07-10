From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH v2 net-next 4/5] drivers/net/ethernet: Fix
 (nearly-)kernel-doc comments for various functions
Date: Tue, 10 Jul 2012 21:56:00 +0100
Message-ID: <1341953760.2605.28.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41180 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753537Ab2GJU4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 16:56:03 -0400
In-Reply-To: <1341953604.2605.24.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix incorrect start markers, wrapped summary lines, missing section
breaks, incorrect separators, and some name mismatches.  Delete
a few that are content-free.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/3com/3c501.c                  |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |   68 +++-----
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |   70 +++-----
 drivers/net/ethernet/atheros/atl1e/atl1e_param.c   |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c           |   41 ++---
 drivers/net/ethernet/atheros/atlx/atl2.c           |   56 +++----
 drivers/net/ethernet/atheros/atlx/atlx.c           |   10 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    2 +-
 drivers/net/ethernet/brocade/bna/bfa_cee.c         |   36 +---
 drivers/net/ethernet/chelsio/cxgb3/sge.c           |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c         |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |    2 +-
 drivers/net/ethernet/ethoc.c                       |    4 +-
 drivers/net/ethernet/freescale/fec.c               |    4 +-
 drivers/net/ethernet/intel/e1000/e1000_hw.c        |    8 +-
 drivers/net/ethernet/intel/e1000e/netdev.c         |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |    1 +
 drivers/net/ethernet/intel/igbvf/netdev.c          |    1 +
 drivers/net/ethernet/intel/igbvf/vf.c              |    5 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |   10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   41 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c       |   38 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     |    8 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    6 +-
 drivers/net/ethernet/micrel/ks8851_mll.c           |    2 +-
 drivers/net/ethernet/micrel/ksz884x.c              |    2 +-
 drivers/net/ethernet/neterion/s2io.c               |   10 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |    2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |   12 +-
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |   10 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   42 +++---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c  |    4 +-
 drivers/net/ethernet/sfc/net_driver.h              |    2 +-
 drivers/net/ethernet/sfc/rx.c                      |    1 +
 drivers/net/ethernet/smsc/smc911x.c                |    6 +-
 drivers/net/ethernet/smsc/smc91x.c                 |    6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c   |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c               |  177 ++++++++++++--------
 drivers/net/ethernet/ti/davinci_emac.c             |   70 ++++----
 drivers/net/ethernet/toshiba/spider_net.c          |    6 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    2 +-
 44 files changed, 378 insertions(+), 410 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/ethernet/3com/3c501.c
index bf73e1a..2038eaa 100644
--- a/drivers/net/ethernet/3com/3c501.c
+++ b/drivers/net/ethernet/3com/3c501.c
@@ -143,7 +143,7 @@ static int irq = 5;
 static int mem_start;
 
 /**
- * el1_probe:		-	probe for a 3c501
+ * el1_probe		-	probe for a 3c501
  * @dev: The device structure passed in to probe.
  *
  * This can be called from two places. The network layer will probe using
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 85717cb..42c13d8 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -166,7 +166,7 @@ static void atl1c_reset_pcie(struct atl1c_hw *hw, u32 flag)
 	msleep(5);
 }
 
-/*
+/**
  * atl1c_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
  */
@@ -179,7 +179,7 @@ static inline void atl1c_irq_enable(struct atl1c_adapter *adapter)
 	}
 }
 
-/*
+/**
  * atl1c_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
  */
@@ -192,7 +192,7 @@ static inline void atl1c_irq_disable(struct atl1c_adapter *adapter)
 	synchronize_irq(adapter->pdev->irq);
 }
 
-/*
+/**
  * atl1c_irq_reset - reset interrupt confiure on the NIC
  * @adapter: board private structure
  */
@@ -220,7 +220,7 @@ static u32 atl1c_wait_until_idle(struct atl1c_hw *hw, u32 modu_ctrl)
 	return data;
 }
 
-/*
+/**
  * atl1c_phy_config - Timer Call-back
  * @data: pointer to netdev cast into an unsigned long
  */
@@ -361,7 +361,7 @@ static void atl1c_del_timer(struct atl1c_adapter *adapter)
 }
 

-/*
+/**
  * atl1c_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
  */
@@ -374,7 +374,7 @@ static void atl1c_tx_timeout(struct net_device *netdev)
 	schedule_work(&adapter->common_task);
 }
 
-/*
+/**
  * atl1c_set_multi - Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
@@ -453,7 +453,7 @@ static void atl1c_restore_vlan(struct atl1c_adapter *adapter)
 	atl1c_vlan_mode(adapter->netdev, adapter->netdev->features);
 }
 
-/*
+/**
  * atl1c_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
  * @p: pointer to an address structure
@@ -518,7 +518,7 @@ static int atl1c_set_features(struct net_device *netdev,
 	return 0;
 }
 
-/*
+/**
  * atl1c_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -577,12 +577,6 @@ static void atl1c_mdio_write(struct net_device *netdev, int phy_id,
 	atl1c_write_phy_reg(&adapter->hw, reg_num, val);
 }
 
-/*
- * atl1c_mii_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
 static int atl1c_mii_ioctl(struct net_device *netdev,
 			   struct ifreq *ifr, int cmd)
 {
@@ -633,12 +627,6 @@ out:
 	return retval;
 }
 
-/*
- * atl1c_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
 static int atl1c_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
@@ -651,7 +639,7 @@ static int atl1c_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	}
 }
 
-/*
+/**
  * atl1c_alloc_queues - Allocate memory for all rings
  * @adapter: board private structure to initialize
  *
@@ -755,7 +743,7 @@ static void __devinit atl1c_patch_assign(struct atl1c_hw *hw)
 		i++;
 	}
 }
-/*
+/**
  * atl1c_sw_init - Initialize general software structures (struct atl1c_adapter)
  * @adapter: board private structure to initialize
  *
@@ -853,7 +841,7 @@ static inline void atl1c_clean_buffer(struct pci_dev *pdev,
 	buffer_info->skb = NULL;
 	ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_FREE);
 }
-/*
+/**
  * atl1c_clean_tx_ring - Free Tx-skb
  * @adapter: board private structure
  */
@@ -878,7 +866,7 @@ static void atl1c_clean_tx_ring(struct atl1c_adapter *adapter,
 	tpd_ring->next_to_use = 0;
 }
 
-/*
+/**
  * atl1c_clean_rx_ring - Free rx-reservation skbs
  * @adapter: board private structure
  */
@@ -931,7 +919,7 @@ static void atl1c_init_ring_ptrs(struct atl1c_adapter *adapter)
 	}
 }
 
-/*
+/**
  * atl1c_free_ring_resources - Free Tx / RX descriptor Resources
  * @adapter: board private structure
  *
@@ -954,7 +942,7 @@ static void atl1c_free_ring_resources(struct atl1c_adapter *adapter)
 	}
 }
 
-/*
+/**
  * atl1c_setup_mem_resources - allocate Tx / RX descriptor resources
  * @adapter: board private structure
  *
@@ -1363,7 +1351,7 @@ static void atl1c_set_aspm(struct atl1c_hw *hw, u16 link_speed)
 	return;
 }
 
-/*
+/**
  * atl1c_configure - Configure Transmit&Receive Unit after Reset
  * @adapter: board private structure
  *
@@ -1477,7 +1465,7 @@ static void atl1c_update_hw_stats(struct atl1c_adapter *adapter)
 	}
 }
 
-/*
+/**
  * atl1c_get_stats - Get System Network Statistics
  * @netdev: network interface device structure
  *
@@ -1558,11 +1546,10 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 	return true;
 }
 
-/*
+/**
  * atl1c_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
- * @pt_regs: CPU registers structure
  */
 static irqreturn_t atl1c_intr(int irq, void *data)
 {
@@ -1813,9 +1800,8 @@ rrs_checked:
 		atl1c_alloc_rx_buffer(adapter);
 }
 
-/*
+/**
  * atl1c_clean - NAPI Rx polling callback
- * @adapter: board private structure
  */
 static int atl1c_clean(struct napi_struct *napi, int budget)
 {
@@ -2270,7 +2256,7 @@ static void atl1c_down(struct atl1c_adapter *adapter)
 	atl1c_reset_dma_ring(adapter);
 }
 
-/*
+/**
  * atl1c_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -2309,7 +2295,7 @@ err_up:
 	return err;
 }
 
-/*
+/**
  * atl1c_close - Disables a network interface
  * @netdev: network interface device structure
  *
@@ -2432,7 +2418,7 @@ static int atl1c_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	return 0;
 }
 
-/*
+/**
  * atl1c_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in atl1c_pci_tbl
@@ -2579,7 +2565,7 @@ err_dma:
 	return err;
 }
 
-/*
+/**
  * atl1c_remove - Device Removal Routine
  * @pdev: PCI device information struct
  *
@@ -2605,7 +2591,7 @@ static void __devexit atl1c_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
-/*
+/**
  * atl1c_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
  * @state: The current pci connection state
@@ -2633,7 +2619,7 @@ static pci_ers_result_t atl1c_io_error_detected(struct pci_dev *pdev,
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
-/*
+/**
  * atl1c_io_slot_reset - called after the pci bus has been reset.
  * @pdev: Pointer to PCI device
  *
@@ -2661,7 +2647,7 @@ static pci_ers_result_t atl1c_io_slot_reset(struct pci_dev *pdev)
 	return PCI_ERS_RESULT_RECOVERED;
 }
 
-/*
+/**
  * atl1c_io_resume - called when traffic can start flowing again.
  * @pdev: Pointer to PCI device
  *
@@ -2704,7 +2690,7 @@ static struct pci_driver atl1c_driver = {
 	.driver.pm = &atl1c_pm_ops,
 };
 
-/*
+/**
  * atl1c_init_module - Driver Registration Routine
  *
  * atl1c_init_module is the first routine called when the driver is
@@ -2715,7 +2701,7 @@ static int __init atl1c_init_module(void)
 	return pci_register_driver(&atl1c_driver);
 }
 
-/*
+/**
  * atl1c_exit_module - Driver Exit Cleanup Routine
  *
  * atl1c_exit_module is called just before the driver is removed
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 0aed82e..a98acc8 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -89,7 +89,7 @@ static const u16 atl1e_pay_load_size[] = {
 	128, 256, 512, 1024, 2048, 4096,
 };
 
-/*
+/**
  * atl1e_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
  */
@@ -102,7 +102,7 @@ static inline void atl1e_irq_enable(struct atl1e_adapter *adapter)
 	}
 }
 
-/*
+/**
  * atl1e_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
  */
@@ -114,7 +114,7 @@ static inline void atl1e_irq_disable(struct atl1e_adapter *adapter)
 	synchronize_irq(adapter->pdev->irq);
 }
 
-/*
+/**
  * atl1e_irq_reset - reset interrupt confiure on the NIC
  * @adapter: board private structure
  */
@@ -126,7 +126,7 @@ static inline void atl1e_irq_reset(struct atl1e_adapter *adapter)
 	AT_WRITE_FLUSH(&adapter->hw);
 }
 
-/*
+/**
  * atl1e_phy_config - Timer Call-back
  * @data: pointer to netdev cast into an unsigned long
  */
@@ -210,7 +210,7 @@ static int atl1e_check_link(struct atl1e_adapter *adapter)
 	return 0;
 }
 
-/*
+/**
  * atl1e_link_chg_task - deal with link change event Out of interrupt context
  * @netdev: network interface device structure
  */
@@ -259,7 +259,7 @@ static void atl1e_cancel_work(struct atl1e_adapter *adapter)
 	cancel_work_sync(&adapter->link_chg_task);
 }
 
-/*
+/**
  * atl1e_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
  */
@@ -271,7 +271,7 @@ static void atl1e_tx_timeout(struct net_device *netdev)
 	schedule_work(&adapter->reset_task);
 }
 
-/*
+/**
  * atl1e_set_multi - Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
@@ -345,7 +345,7 @@ static void atl1e_restore_vlan(struct atl1e_adapter *adapter)
 	atl1e_vlan_mode(adapter->netdev, adapter->netdev->features);
 }
 
-/*
+/**
  * atl1e_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
  * @p: pointer to an address structure
@@ -397,7 +397,7 @@ static int atl1e_set_features(struct net_device *netdev,
 	return 0;
 }
 
-/*
+/**
  * atl1e_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -449,12 +449,6 @@ static void atl1e_mdio_write(struct net_device *netdev, int phy_id,
 	atl1e_write_phy_reg(&adapter->hw, reg_num & MDIO_REG_ADDR_MASK, val);
 }
 
-/*
- * atl1e_mii_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
 static int atl1e_mii_ioctl(struct net_device *netdev,
 			   struct ifreq *ifr, int cmd)
 {
@@ -505,12 +499,6 @@ out:
 
 }
 
-/*
- * atl1e_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
 static int atl1e_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
@@ -541,7 +529,7 @@ static void atl1e_setup_pcicmd(struct pci_dev *pdev)
 	msleep(1);
 }
 
-/*
+/**
  * atl1e_alloc_queues - Allocate memory for all rings
  * @adapter: board private structure to initialize
  *
@@ -551,7 +539,7 @@ static int __devinit atl1e_alloc_queues(struct atl1e_adapter *adapter)
 	return 0;
 }
 
-/*
+/**
  * atl1e_sw_init - Initialize general software structures (struct atl1e_adapter)
  * @adapter: board private structure to initialize
  *
@@ -635,7 +623,7 @@ static int __devinit atl1e_sw_init(struct atl1e_adapter *adapter)
 	return 0;
 }
 
-/*
+/**
  * atl1e_clean_tx_ring - Free Tx-skb
  * @adapter: board private structure
  */
@@ -678,7 +666,7 @@ static void atl1e_clean_tx_ring(struct atl1e_adapter *adapter)
 				ring_count);
 }
 
-/*
+/**
  * atl1e_clean_rx_ring - Free rx-reservation skbs
  * @adapter: board private structure
  */
@@ -761,7 +749,7 @@ static void atl1e_init_ring_ptrs(struct atl1e_adapter *adapter)
 	}
 }
 
-/*
+/**
  * atl1e_free_ring_resources - Free Tx / RX descriptor Resources
  * @adapter: board private structure
  *
@@ -786,7 +774,7 @@ static void atl1e_free_ring_resources(struct atl1e_adapter *adapter)
 	}
 }
 
-/*
+/**
  * atl1e_setup_mem_resources - allocate Tx / RX descriptor resources
  * @adapter: board private structure
  *
@@ -1075,7 +1063,7 @@ static void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter)
 	AT_WRITE_REG(hw, REG_MAC_CTRL, value);
 }
 
-/*
+/**
  * atl1e_configure - Configure Transmit&Receive Unit after Reset
  * @adapter: board private structure
  *
@@ -1145,7 +1133,7 @@ static int atl1e_configure(struct atl1e_adapter *adapter)
 	return 0;
 }
 
-/*
+/**
  * atl1e_get_stats - Get System Network Statistics
  * @netdev: network interface device structure
  *
@@ -1257,11 +1245,10 @@ static bool atl1e_clean_tx_irq(struct atl1e_adapter *adapter)
 	return true;
 }
 
-/*
+/**
  * atl1e_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
- * @pt_regs: CPU registers structure
  */
 static irqreturn_t atl1e_intr(int irq, void *data)
 {
@@ -1489,9 +1476,8 @@ fatal_err:
 		schedule_work(&adapter->reset_task);
 }
 
-/*
+/**
  * atl1e_clean - NAPI Rx polling callback
- * @adapter: board private structure
  */
 static int atl1e_clean(struct napi_struct *napi, int budget)
 {
@@ -1956,7 +1942,7 @@ void atl1e_down(struct atl1e_adapter *adapter)
 	atl1e_clean_rx_ring(adapter);
 }
 
-/*
+/**
  * atl1e_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -2002,7 +1988,7 @@ err_req_irq:
 	return err;
 }
 
-/*
+/**
  * atl1e_close - Disables a network interface
  * @netdev: network interface device structure
  *
@@ -2238,7 +2224,7 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	return 0;
 }
 
-/*
+/**
  * atl1e_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in atl1e_pci_tbl
@@ -2392,7 +2378,7 @@ err_dma:
 	return err;
 }
 
-/*
+/**
  * atl1e_remove - Device Removal Routine
  * @pdev: PCI device information struct
  *
@@ -2424,7 +2410,7 @@ static void __devexit atl1e_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-/*
+/**
  * atl1e_io_error_detected - called when PCI error is detected
  * @pdev: Pointer to PCI device
  * @state: The current pci connection state
@@ -2452,7 +2438,7 @@ atl1e_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
-/*
+/**
  * atl1e_io_slot_reset - called after the pci bus has been reset.
  * @pdev: Pointer to PCI device
  *
@@ -2479,7 +2465,7 @@ static pci_ers_result_t atl1e_io_slot_reset(struct pci_dev *pdev)
 	return PCI_ERS_RESULT_RECOVERED;
 }
 
-/*
+/**
  * atl1e_io_resume - called when traffic can start flowing again.
  * @pdev: Pointer to PCI device
  *
@@ -2523,7 +2509,7 @@ static struct pci_driver atl1e_driver = {
 	.err_handler = &atl1e_err_handler
 };
 
-/*
+/**
  * atl1e_init_module - Driver Registration Routine
  *
  * atl1e_init_module is the first routine called when the driver is
@@ -2534,7 +2520,7 @@ static int __init atl1e_init_module(void)
 	return pci_register_driver(&atl1e_driver);
 }
 
-/*
+/**
  * atl1e_exit_module - Driver Exit Cleanup Routine
  *
  * atl1e_exit_module is called just before the driver is removed
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_param.c b/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
index 0ce60b6..b5086f1 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
@@ -168,7 +168,7 @@ static int __devinit atl1e_validate_option(int *value, struct atl1e_option *opt,
 	return -1;
 }
 
-/*
+/**
  * atl1e_check_options - Range Checking for Command Line Parameters
  * @adapter: board private structure
  *
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 149a294..f2402f3 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -195,7 +195,7 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt,
 	return -1;
 }
 
-/*
+/**
  * atl1_check_options - Range Checking for Command Line Parameters
  * @adapter: board private structure
  *
@@ -937,7 +937,7 @@ static void atl1_set_mac_addr(struct atl1_hw *hw)
 	iowrite32(value, (hw->hw_addr + REG_MAC_STA_ADDR) + (1 << 2));
 }
 
-/*
+/**
  * atl1_sw_init - Initialize general software structures (struct atl1_adapter)
  * @adapter: board private structure to initialize
  *
@@ -1014,12 +1014,6 @@ static void mdio_write(struct net_device *netdev, int phy_id, int reg_num,
 	atl1_write_phy_reg(&adapter->hw, reg_num, val);
 }
 
-/*
- * atl1_mii_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
 static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -1036,7 +1030,7 @@ static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return retval;
 }
 
-/*
+/**
  * atl1_setup_mem_resources - allocate Tx / RX descriptor resources
  * @adapter: board private structure
  *
@@ -1147,7 +1141,7 @@ static void atl1_init_ring_ptrs(struct atl1_adapter *adapter)
 	atomic_set(&rrd_ring->next_to_clean, 0);
 }
 
-/*
+/**
  * atl1_clean_rx_ring - Free RFD Buffers
  * @adapter: board private structure
  */
@@ -1187,7 +1181,7 @@ static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
 	atomic_set(&rrd_ring->next_to_clean, 0);
 }
 
-/*
+/**
  * atl1_clean_tx_ring - Free Tx Buffers
  * @adapter: board private structure
  */
@@ -1227,7 +1221,7 @@ static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
 	atomic_set(&tpd_ring->next_to_clean, 0);
 }
 
-/*
+/**
  * atl1_free_ring_resources - Free Tx / RX descriptor Resources
  * @adapter: board private structure
  *
@@ -1470,7 +1464,7 @@ static void set_flow_ctrl_new(struct atl1_hw *hw)
 	iowrite32(value, hw->hw_addr + REG_RXQ_RRD_PAUSE_THRESH);
 }
 
-/*
+/**
  * atl1_configure - Configure Transmit&Receive Unit after Reset
  * @adapter: board private structure
  *
@@ -1844,7 +1838,7 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 	}
 }
 
-/*
+/**
  * atl1_alloc_rx_buffers - Replace used receive buffers
  * @adapter: address of board private structure
  */
@@ -2489,11 +2483,10 @@ static inline int atl1_sched_rings_clean(struct atl1_adapter* adapter)
 	return 1;
 }
 
-/*
+/**
  * atl1_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
- * @pt_regs: CPU registers structure
  */
 static irqreturn_t atl1_intr(int irq, void *data)
 {
@@ -2574,7 +2567,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 }
 

-/*
+/**
  * atl1_phy_config - Timer Call-back
  * @data: pointer to netdev cast into an unsigned long
  */
@@ -2693,7 +2686,7 @@ static void atl1_reset_dev_task(struct work_struct *work)
 	netif_device_attach(netdev);
 }
 
-/*
+/**
  * atl1_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -2727,7 +2720,7 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
-/*
+/**
  * atl1_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -2762,7 +2755,7 @@ err_up:
 	return err;
 }
 
-/*
+/**
  * atl1_close - Disables a network interface
  * @netdev: network interface device structure
  *
@@ -2930,7 +2923,7 @@ static const struct net_device_ops atl1_netdev_ops = {
 #endif
 };
 
-/*
+/**
  * atl1_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in atl1_pci_tbl
@@ -3111,7 +3104,7 @@ err_request_regions:
 	return err;
 }
 
-/*
+/**
  * atl1_remove - Device Removal Routine
  * @pdev: PCI device information struct
  *
@@ -3158,7 +3151,7 @@ static struct pci_driver atl1_driver = {
 	.driver.pm = ATL1_PM_OPS,
 };
 
-/*
+/**
  * atl1_exit_module - Driver Exit Cleanup Routine
  *
  * atl1_exit_module is called just before the driver is removed
@@ -3169,7 +3162,7 @@ static void __exit atl1_exit_module(void)
 	pci_unregister_driver(&atl1_driver);
 }
 
-/*
+/**
  * atl1_init_module - Driver Registration Routine
  *
  * atl1_init_module is the first routine called when the driver is
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 6762dc4..7c0b7e2 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -75,7 +75,7 @@ static void atl2_set_ethtool_ops(struct net_device *netdev);
 
 static void atl2_check_options(struct atl2_adapter *adapter);
 
-/*
+/**
  * atl2_sw_init - Initialize general software structures (struct atl2_adapter)
  * @adapter: board private structure to initialize
  *
@@ -123,7 +123,7 @@ static int __devinit atl2_sw_init(struct atl2_adapter *adapter)
 	return 0;
 }
 
-/*
+/**
  * atl2_set_multi - Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
@@ -177,7 +177,7 @@ static void init_ring_ptrs(struct atl2_adapter *adapter)
 	adapter->txs_next_clear = 0;
 }
 
-/*
+/**
  * atl2_configure - Configure Transmit&Receive Unit after Reset
  * @adapter: board private structure
  *
@@ -283,7 +283,7 @@ static int atl2_configure(struct atl2_adapter *adapter)
 	return value;
 }
 
-/*
+/**
  * atl2_setup_ring_resources - allocate Tx / RX descriptor resources
  * @adapter: board private structure
  *
@@ -340,7 +340,7 @@ static s32 atl2_setup_ring_resources(struct atl2_adapter *adapter)
 	return 0;
 }
 
-/*
+/**
  * atl2_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
  */
@@ -350,7 +350,7 @@ static inline void atl2_irq_enable(struct atl2_adapter *adapter)
 	ATL2_WRITE_FLUSH(&adapter->hw);
 }
 
-/*
+/**
  * atl2_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
  */
@@ -599,11 +599,10 @@ static inline void atl2_clear_phy_int(struct atl2_adapter *adapter)
 	spin_unlock(&adapter->stats_lock);
 }
 
-/*
+/**
  * atl2_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
- * @pt_regs: CPU registers structure
  */
 static irqreturn_t atl2_intr(int irq, void *data)
 {
@@ -679,7 +678,7 @@ static int atl2_request_irq(struct atl2_adapter *adapter)
 		netdev);
 }
 
-/*
+/**
  * atl2_free_ring_resources - Free Tx / RX descriptor Resources
  * @adapter: board private structure
  *
@@ -692,7 +691,7 @@ static void atl2_free_ring_resources(struct atl2_adapter *adapter)
 		adapter->ring_dma);
 }
 
-/*
+/**
  * atl2_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -798,7 +797,7 @@ static void atl2_free_irq(struct atl2_adapter *adapter)
 #endif
 }
 
-/*
+/**
  * atl2_close - Disables a network interface
  * @netdev: network interface device structure
  *
@@ -918,7 +917,7 @@ static netdev_tx_t atl2_xmit_frame(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-/*
+/**
  * atl2_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -943,7 +942,7 @@ static int atl2_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
-/*
+/**
  * atl2_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
  * @p: pointer to an address structure
@@ -969,12 +968,6 @@ static int atl2_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
-/*
- * atl2_mii_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
 static int atl2_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	struct atl2_adapter *adapter = netdev_priv(netdev);
@@ -1011,12 +1004,6 @@ static int atl2_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return 0;
 }
 
-/*
- * atl2_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
 static int atl2_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
@@ -1033,7 +1020,7 @@ static int atl2_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	}
 }
 
-/*
+/**
  * atl2_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
  */
@@ -1045,7 +1032,7 @@ static void atl2_tx_timeout(struct net_device *netdev)
 	schedule_work(&adapter->reset_task);
 }
 
-/*
+/**
  * atl2_watchdog - Timer Call-back
  * @data: pointer to netdev cast into an unsigned long
  */
@@ -1070,7 +1057,7 @@ static void atl2_watchdog(unsigned long data)
 	}
 }
 
-/*
+/**
  * atl2_phy_config - Timer Call-back
  * @data: pointer to netdev cast into an unsigned long
  */
@@ -1274,9 +1261,8 @@ static int atl2_check_link(struct atl2_adapter *adapter)
 	return 0;
 }
 
-/*
+/**
  * atl2_link_chg_task - deal with link change event Out of interrupt context
- * @netdev: network interface device structure
  */
 static void atl2_link_chg_task(struct work_struct *work)
 {
@@ -1341,7 +1327,7 @@ static const struct net_device_ops atl2_netdev_ops = {
 #endif
 };
 
-/*
+/**
  * atl2_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in atl2_pci_tbl
@@ -1501,7 +1487,7 @@ err_dma:
 	return err;
 }
 
-/*
+/**
  * atl2_remove - Device Removal Routine
  * @pdev: PCI device information struct
  *
@@ -1728,7 +1714,7 @@ static struct pci_driver atl2_driver = {
 	.shutdown = atl2_shutdown,
 };
 
-/*
+/**
  * atl2_init_module - Driver Registration Routine
  *
  * atl2_init_module is the first routine called when the driver is
@@ -1743,7 +1729,7 @@ static int __init atl2_init_module(void)
 }
 module_init(atl2_init_module);
 
-/*
+/**
  * atl2_exit_module - Driver Exit Cleanup Routine
  *
  * atl2_exit_module is called just before the driver is removed
@@ -2997,7 +2983,7 @@ static int __devinit atl2_validate_option(int *value, struct atl2_option *opt)
 	return -1;
 }
 
-/*
+/**
  * atl2_check_options - Range Checking for Command Line Parameters
  * @adapter: board private structure
  *
diff --git a/drivers/net/ethernet/atheros/atlx/atlx.c b/drivers/net/ethernet/atheros/atlx/atlx.c
index b4f3aa4..77ffbc4 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -64,7 +64,7 @@ static int atlx_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	}
 }
 
-/*
+/**
  * atlx_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
  * @p: pointer to an address structure
@@ -115,7 +115,7 @@ static void atlx_check_for_link(struct atlx_adapter *adapter)
 	schedule_work(&adapter->link_chg_task);
 }
 
-/*
+/**
  * atlx_set_multi - Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
@@ -162,7 +162,7 @@ static inline void atlx_imr_set(struct atlx_adapter *adapter,
 	ioread32(adapter->hw.hw_addr + REG_IMR);
 }
 
-/*
+/**
  * atlx_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
  */
@@ -172,7 +172,7 @@ static void atlx_irq_enable(struct atlx_adapter *adapter)
 	adapter->int_enabled = true;
 }
 
-/*
+/**
  * atlx_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
  */
@@ -193,7 +193,7 @@ static void atlx_clear_phy_int(struct atlx_adapter *adapter)
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
-/*
+/**
  * atlx_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 53659f3..dfa757e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -90,7 +90,7 @@ void bnx2x_send_unload_done(struct bnx2x *bp);
  * bnx2x_config_rss_pf - configure RSS parameters in a PF.
  *
  * @bp:			driver handle
- * @rss_obj		RSS object to use
+ * @rss_obj:		RSS object to use
  * @ind_table:		indirection table to configure
  * @config_hash:	re-configure RSS hash keys configuration
  */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_cee.c b/drivers/net/ethernet/brocade/bna/bfa_cee.c
index 689e5e1..8532a81 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cee.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_cee.c
@@ -52,13 +52,7 @@ bfa_cee_format_lldp_cfg(struct bfa_cee_lldp_cfg *lldp_cfg)
 }
 
 /**
- * bfa_cee_attr_meminfo()
- *
- * @brief Returns the size of the DMA memory needed by CEE attributes
- *
- * @param[in] void
- *
- * @return Size of DMA region
+ * bfa_cee_attr_meminfo - Returns the size of the DMA memory needed by CEE attributes
  */
 static u32
 bfa_cee_attr_meminfo(void)
@@ -66,13 +60,7 @@ bfa_cee_attr_meminfo(void)
 	return roundup(sizeof(struct bfa_cee_attr), BFA_DMA_ALIGN_SZ);
 }
 /**
- * bfa_cee_stats_meminfo()
- *
- * @brief Returns the size of the DMA memory needed by CEE stats
- *
- * @param[in] void
- *
- * @return Size of DMA region
+ * bfa_cee_stats_meminfo - Returns the size of the DMA memory needed by CEE stats
  */
 static u32
 bfa_cee_stats_meminfo(void)
@@ -81,14 +69,10 @@ bfa_cee_stats_meminfo(void)
 }
 
 /**
- * bfa_cee_get_attr_isr()
+ * bfa_cee_get_attr_isr - CEE ISR for get-attributes responses from f/w
  *
- * @brief CEE ISR for get-attributes responses from f/w
- *
- * @param[in] cee - Pointer to the CEE module
- *            status - Return status from the f/w
- *
- * @return void
+ * @cee: Pointer to the CEE module
+ * @status: Return status from the f/w
  */
 static void
 bfa_cee_get_attr_isr(struct bfa_cee *cee, enum bfa_status status)
@@ -105,14 +89,10 @@ bfa_cee_get_attr_isr(struct bfa_cee *cee, enum bfa_status status)
 }
 
 /**
- * bfa_cee_get_attr_isr()
+ * bfa_cee_get_attr_isr - CEE ISR for get-stats responses from f/w
  *
- * @brief CEE ISR for get-stats responses from f/w
- *
- * @param[in] cee - Pointer to the CEE module
- *            status - Return status from the f/w
- *
- * @return void
+ * @cee: Pointer to the CEE module
+ * @status: Return status from the f/w
  */
 static void
 bfa_cee_get_stats_isr(struct bfa_cee *cee, enum bfa_status status)
diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index cfb60e1..dd901c5 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -2877,7 +2877,7 @@ static void sge_timer_tx(unsigned long data)
 	mod_timer(&qs->tx_reclaim_timer, jiffies + next_period);
 }
 
-/*
+/**
  *	sge_timer_rx - perform periodic maintenance of an SGE qset
  *	@data: the SGE queue set to maintain
  *
diff --git a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
index 44ac2f4..bff8a3c 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
@@ -1076,7 +1076,7 @@ static int t3_flash_erase_sectors(struct adapter *adapter, int start, int end)
 	return 0;
 }
 
-/*
+/**
  *	t3_load_fw - download firmware
  *	@adapter: the adapter
  *	@fw_data: the firmware image to write
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 32e1dd5..fa947df 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2010,7 +2010,7 @@ int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
-/*
+/**
  *     t4_mem_win_read_len - read memory through PCIE memory window
  *     @adap: the adapter
  *     @addr: address of first byte requested aligned on 32b.
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index a381678..2029788 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -902,7 +902,7 @@ static const struct net_device_ops ethoc_netdev_ops = {
 };
 
 /**
- * ethoc_probe() - initialize OpenCores ethernet MAC
+ * ethoc_probe - initialize OpenCores ethernet MAC
  * pdev:	platform device
  */
 static int __devinit ethoc_probe(struct platform_device *pdev)
@@ -1140,7 +1140,7 @@ out:
 }
 
 /**
- * ethoc_remove() - shutdown OpenCores ethernet MAC
+ * ethoc_remove - shutdown OpenCores ethernet MAC
  * @pdev:	platform device
  */
 static int __devexit ethoc_remove(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index dafd797..fffd205 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1389,8 +1389,8 @@ fec_set_mac_address(struct net_device *ndev, void *p)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-/*
- * fec_poll_controller: FEC Poll controller function
+/**
+ * fec_poll_controller - FEC Poll controller function
  * @dev: The FEC network adapter
  *
  * Polled functionality used by netconsole and others in non interrupt mode
diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index c526279e4..3d68395 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -399,7 +399,7 @@ void e1000_set_media_type(struct e1000_hw *hw)
 }
 
 /**
- * e1000_reset_hw: reset the hardware completely
+ * e1000_reset_hw - reset the hardware completely
  * @hw: Struct containing variables accessed by shared code
  *
  * Reset the transmit and receive units; mask and clear all interrupts.
@@ -546,7 +546,7 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 }
 
 /**
- * e1000_init_hw: Performs basic configuration of the adapter.
+ * e1000_init_hw - Performs basic configuration of the adapter.
  * @hw: Struct containing variables accessed by shared code
  *
  * Assumes that the controller has previously been reset and is in a
@@ -2591,7 +2591,7 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
  * @hw: Struct containing variables accessed by shared code
  * @speed: Speed of the connection
  * @duplex: Duplex setting of the connection
-
+ *
  * Detects the current speed and duplex settings of the hardware.
  */
 s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex)
@@ -2959,7 +2959,7 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
  * @hw: Struct containing variables accessed by shared code
  * @reg_addr: address of the PHY register to write
  * @data: data to write to the PHY
-
+ *
  * Writes a value to a PHY register
  */
 s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 phy_data)
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index a166efc..ca477e8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2159,7 +2159,7 @@ void e1000e_release_hw_control(struct e1000_adapter *adapter)
 }
 
 /**
- * @e1000_alloc_ring - allocate memory for a ring structure
+ * e1000_alloc_ring_dma - allocate memory for a ring structure
  **/
 static int e1000_alloc_ring_dma(struct e1000_adapter *adapter,
 				struct e1000_ring *ring)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 01ced68..60e3075 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5777,6 +5777,7 @@ static void igb_tx_hwtstamp(struct igb_q_vector *q_vector,
 /**
  * igb_clean_tx_irq - Reclaim resources after transmit completes
  * @q_vector: pointer to q_vector containing needed info
+ *
  * returns true if ring is completely cleaned
  **/
 static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 8ec74b0..0696abf 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -766,6 +766,7 @@ static void igbvf_set_itr(struct igbvf_adapter *adapter)
 /**
  * igbvf_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
+ *
  * returns true if ring is completely cleaned
  **/
 static bool igbvf_clean_tx_irq(struct igbvf_ring *tx_ring)
diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index 30a6cc4..eea0e10 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -283,7 +283,8 @@ static s32 e1000_set_vfta_vf(struct e1000_hw *hw, u16 vid, bool set)
 	return err;
 }
 
-/** e1000_rlpml_set_vf - Set the maximum receive packet length
+/**
+ *  e1000_rlpml_set_vf - Set the maximum receive packet length
  *  @hw: pointer to the HW structure
  *  @max_size: value to assign to max frame size
  **/
@@ -302,7 +303,7 @@ void e1000_rlpml_set_vf(struct e1000_hw *hw, u16 max_size)
  *  e1000_rar_set_vf - set device MAC address
  *  @hw: pointer to the HW structure
  *  @addr: pointer to the receive address
- *  @index receive address array register
+ *  @index: receive address array register
  **/
 static void e1000_rar_set_vf(struct e1000_hw *hw, u8 * addr, u32 index)
 {
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 5fce363..aab649f 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -2276,9 +2276,9 @@ static void ixgb_netpoll(struct net_device *dev)
 #endif
 
 /**
- * ixgb_io_error_detected() - called when PCI error is detected
- * @pdev    pointer to pci device with error
- * @state   pci channel state after error
+ * ixgb_io_error_detected - called when PCI error is detected
+ * @pdev:    pointer to pci device with error
+ * @state:   pci channel state after error
  *
  * This callback is called by the PCI subsystem whenever
  * a PCI bus error is detected.
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 77ac41f..bb7fde4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3132,7 +3132,7 @@ s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
 }
 
 /**
- *  ixgbe_get_wwn_prefix_generic Get alternative WWNN/WWPN prefix from
+ *  ixgbe_get_wwn_prefix_generic - Get alternative WWNN/WWPN prefix from
  *  the EEPROM
  *  @hw: pointer to hardware structure
  *  @wwnn_prefix: the alternative WWNN prefix
@@ -3325,6 +3325,7 @@ void ixgbe_set_rxpba_generic(struct ixgbe_hw *hw,
  *  ixgbe_calculate_checksum - Calculate checksum for buffer
  *  @buffer: pointer to EEPROM
  *  @length: size of EEPROM to calculate a checksum for
+ *
  *  Calculates the checksum for some buffer on a specified length.  The
  *  checksum calculated is returned.
  **/
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index bc07933..0ee4dbf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -38,7 +38,7 @@
 
 /**
  * ixgbe_fcoe_clear_ddp - clear the given ddp context
- * @ddp - ptr to the ixgbe_fcoe_ddp
+ * @ddp: ptr to the ixgbe_fcoe_ddp
  *
  * Returns : none
  *
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index c377706..f36c3c3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -252,7 +252,7 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_set_sriov_queues: Allocate queues for IOV use
+ * ixgbe_set_sriov_queues - Allocate queues for IOV use
  * @adapter: board private structure to initialize
  *
  * IOV doesn't actually use anything, so just NAK the
@@ -265,7 +265,7 @@ static inline bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_set_rss_queues: Allocate queues for RSS
+ * ixgbe_set_rss_queues - Allocate queues for RSS
  * @adapter: board private structure to initialize
  *
  * This is our "base" multiqueue mode.  RSS (Receive Side Scaling) will try
@@ -288,7 +288,7 @@ static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_set_fdir_queues: Allocate queues for Flow Director
+ * ixgbe_set_fdir_queues - Allocate queues for Flow Director
  * @adapter: board private structure to initialize
  *
  * Flow Director is an advanced Rx filter, attempting to get Rx flows back
@@ -323,7 +323,7 @@ static inline bool ixgbe_set_fdir_queues(struct ixgbe_adapter *adapter)
 
 #ifdef IXGBE_FCOE
 /**
- * ixgbe_set_fcoe_queues: Allocate queues for Fiber Channel over Ethernet (FCoE)
+ * ixgbe_set_fcoe_queues - Allocate queues for Fiber Channel over Ethernet (FCoE)
  * @adapter: board private structure to initialize
  *
  * FCoE RX FCRETA can use up to 8 rx queues for up to 8 different exchanges.
@@ -410,7 +410,7 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 #endif
 
 /**
- * ixgbe_set_num_queues: Allocate queues for device, feature dependent
+ * ixgbe_set_num_queues - Allocate queues for device, feature dependent
  * @adapter: board private structure to initialize
  *
  * This is the top level queue allocation routine.  The order here is very
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5afbb37..9313f5c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -516,7 +516,7 @@ static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
 			ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
 }
 
-/*
+/**
  * ixgbe_set_ivar - set the IVAR registers, mapping interrupt causes to vectors
  * @adapter: pointer to adapter struct
  * @direction: 0 for Rx, 1 for Tx, -1 for other causes
@@ -3591,7 +3591,7 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 }
 
 #ifdef CONFIG_IXGBE_DCB
-/*
+/**
  * ixgbe_configure_dcb - Configure DCB hardware
  * @adapter: ixgbe adapter struct
  *
@@ -3658,11 +3658,11 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 /* Additional bittime to account for IXGBE framing */
 #define IXGBE_ETH_FRAMING 20
 
-/*
+/**
  * ixgbe_hpbthresh - calculate high water mark for flow control
  *
  * @adapter: board private structure to calculate for
- * @pb - packet buffer to calculate
+ * @pb: packet buffer to calculate
  */
 static int ixgbe_hpbthresh(struct ixgbe_adapter *adapter, int pb)
 {
@@ -3722,11 +3722,11 @@ static int ixgbe_hpbthresh(struct ixgbe_adapter *adapter, int pb)
 	return marker;
 }
 
-/*
+/**
  * ixgbe_lpbthresh - calculate low water mark for for flow control
  *
  * @adapter: board private structure to calculate for
- * @pb - packet buffer to calculate
+ * @pb: packet buffer to calculate
  */
 static int ixgbe_lpbthresh(struct ixgbe_adapter *adapter)
 {
@@ -5243,7 +5243,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_fdir_reinit_subtask - worker thread to reinit FDIR filter table
- * @adapter - pointer to the device adapter structure
+ * @adapter: pointer to the device adapter structure
  **/
 static void ixgbe_fdir_reinit_subtask(struct ixgbe_adapter *adapter)
 {
@@ -5279,7 +5279,7 @@ static void ixgbe_fdir_reinit_subtask(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_check_hang_subtask - check for hung queues and dropped interrupts
- * @adapter - pointer to the device adapter structure
+ * @adapter: pointer to the device adapter structure
  *
  * This function serves two purposes.  First it strobes the interrupt lines
  * in order to make certain interrupts are occurring.  Secondly it sets the
@@ -5327,8 +5327,8 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_watchdog_update_link - update the link status
- * @adapter - pointer to the device adapter structure
- * @link_speed - pointer to a u32 to store the link_speed
+ * @adapter: pointer to the device adapter structure
+ * @link_speed: pointer to a u32 to store the link_speed
  **/
 static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 {
@@ -5371,7 +5371,7 @@ static void ixgbe_watchdog_update_link(struct ixgbe_adapter *adapter)
 /**
  * ixgbe_watchdog_link_is_up - update netif_carrier status and
  *                             print link up message
- * @adapter - pointer to the device adapter structure
+ * @adapter: pointer to the device adapter structure
  **/
 static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 {
@@ -5431,7 +5431,7 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 /**
  * ixgbe_watchdog_link_is_down - update netif_carrier status and
  *                               print link down message
- * @adapter - pointer to the adapter structure
+ * @adapter: pointer to the adapter structure
  **/
 static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 {
@@ -5459,7 +5459,7 @@ static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_watchdog_flush_tx - flush queues on link down
- * @adapter - pointer to the device adapter structure
+ * @adapter: pointer to the device adapter structure
  **/
 static void ixgbe_watchdog_flush_tx(struct ixgbe_adapter *adapter)
 {
@@ -5508,7 +5508,7 @@ static void ixgbe_spoof_check(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_watchdog_subtask - check and bring link up
- * @adapter - pointer to the device adapter structure
+ * @adapter: pointer to the device adapter structure
  **/
 static void ixgbe_watchdog_subtask(struct ixgbe_adapter *adapter)
 {
@@ -5532,7 +5532,7 @@ static void ixgbe_watchdog_subtask(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_sfp_detection_subtask - poll for SFP+ cable
- * @adapter - the ixgbe adapter structure
+ * @adapter: the ixgbe adapter structure
  **/
 static void ixgbe_sfp_detection_subtask(struct ixgbe_adapter *adapter)
 {
@@ -5599,7 +5599,7 @@ sfp_out:
 
 /**
  * ixgbe_sfp_link_config_subtask - set up link SFP after module install
- * @adapter - the ixgbe adapter structure
+ * @adapter: the ixgbe adapter structure
  **/
 static void ixgbe_sfp_link_config_subtask(struct ixgbe_adapter *adapter)
 {
@@ -6586,8 +6586,9 @@ static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
 }
 
 #ifdef CONFIG_IXGBE_DCB
-/* ixgbe_validate_rtr - verify 802.1Qp to Rx packet buffer mapping is valid.
- * #adapter: pointer to ixgbe_adapter
+/**
+ * ixgbe_validate_rtr - verify 802.1Qp to Rx packet buffer mapping is valid.
+ * @adapter: pointer to ixgbe_adapter
  * @tc: number of traffic classes currently enabled
  *
  * Configure a valid 802.1Qp to Rx packet buffer mapping ie confirm
@@ -6622,8 +6623,8 @@ static void ixgbe_validate_rtr(struct ixgbe_adapter *adapter, u8 tc)
 	return;
 }
 
-/* ixgbe_setup_tc - routine to configure net_device for multiple traffic
- * classes.
+/**
+ * ixgbe_setup_tc - configure net_device for multiple traffic classes
  *
  * @netdev: net device to configure
  * @tc: number of traffic classes to enable
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index daddd84..3456d56 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -107,7 +107,7 @@ static struct sock_filter ptp_filter[] = {
 
 /**
  * ixgbe_ptp_read - read raw cycle counter (to be used by time counter)
- * @cc - the cyclecounter structure
+ * @cc: the cyclecounter structure
  *
  * this function reads the cyclecounter registers and is called by the
  * cyclecounter structure used to construct a ns counter from the
@@ -128,8 +128,8 @@ static cycle_t ixgbe_ptp_read(const struct cyclecounter *cc)
 
 /**
  * ixgbe_ptp_adjfreq
- * @ptp - the ptp clock structure
- * @ppb - parts per billion adjustment from base
+ * @ptp: the ptp clock structure
+ * @ppb: parts per billion adjustment from base
  *
  * adjust the frequency of the ptp cycle counter by the
  * indicated ppb from the base frequency.
@@ -175,8 +175,8 @@ static int ixgbe_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 
 /**
  * ixgbe_ptp_adjtime
- * @ptp - the ptp clock structure
- * @delta - offset to adjust the cycle counter by
+ * @ptp: the ptp clock structure
+ * @delta: offset to adjust the cycle counter by
  *
  * adjust the timer by resetting the timecounter structure.
  */
@@ -203,8 +203,8 @@ static int ixgbe_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 
 /**
  * ixgbe_ptp_gettime
- * @ptp - the ptp clock structure
- * @ts - timespec structure to hold the current time value
+ * @ptp: the ptp clock structure
+ * @ts: timespec structure to hold the current time value
  *
  * read the timecounter and return the correct value on ns,
  * after converting it into a struct timespec.
@@ -229,8 +229,8 @@ static int ixgbe_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 
 /**
  * ixgbe_ptp_settime
- * @ptp - the ptp clock structure
- * @ts - the timespec containing the new time for the cycle counter
+ * @ptp: the ptp clock structure
+ * @ts: the timespec containing the new time for the cycle counter
  *
  * reset the timecounter to use a new base value instead of the kernel
  * wall timer value.
@@ -256,9 +256,9 @@ static int ixgbe_ptp_settime(struct ptp_clock_info *ptp,
 
 /**
  * ixgbe_ptp_enable
- * @ptp - the ptp clock structure
- * @rq - the requested feature to change
- * @on - whether to enable or disable the feature
+ * @ptp: the ptp clock structure
+ * @rq: the requested feature to change
+ * @on: whether to enable or disable the feature
  *
  * enable (or disable) ancillary features of the phc subsystem.
  * our driver only supports the PPS feature on the X540
@@ -294,8 +294,8 @@ static int ixgbe_ptp_enable(struct ptp_clock_info *ptp,
 
 /**
  * ixgbe_ptp_check_pps_event
- * @adapter - the private adapter structure
- * @eicr - the interrupt cause register value
+ * @adapter: the private adapter structure
+ * @eicr: the interrupt cause register value
  *
  * This function is called by the interrupt routine when checking for
  * interrupts. It will check and handle a pps event.
@@ -325,8 +325,8 @@ void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
 
 /**
  * ixgbe_ptp_enable_sdp
- * @hw - the hardware private structure
- * @shift - the clock shift for calculating nanoseconds
+ * @hw: the hardware private structure
+ * @shift: the clock shift for calculating nanoseconds
  *
  * this function enables the clock out feature on the sdp0 for the
  * X540 device. It will create a 1second periodic output that can be
@@ -399,7 +399,7 @@ static void ixgbe_ptp_enable_sdp(struct ixgbe_hw *hw, int shift)
 
 /**
  * ixgbe_ptp_disable_sdp
- * @hw - the private hardware structure
+ * @hw: the private hardware structure
  *
  * this function disables the auxiliary SDP clock out feature
  */
@@ -769,7 +769,7 @@ int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 
 /**
  * ixgbe_ptp_start_cyclecounter - create the cycle counter from hw
- * @adapter - pointer to the adapter structure
+ * @adapter: pointer to the adapter structure
  *
  * this function initializes the timecounter and cyclecounter
  * structures for use in generated a ns counter from the arbitrary
@@ -905,7 +905,7 @@ void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter)
 
 /**
  * ixgbe_ptp_init
- * @adapter - the ixgbe private adapter structure
+ * @adapter: the ixgbe private adapter structure
  *
  * This function performs the required steps for enabling ptp
  * support. If ptp support has already been loaded it simply calls the
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index 2334fce..16ddf14 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -95,11 +95,11 @@ static ssize_t ixgbe_hwmon_show_maxopthresh(struct device *dev,
 	return sprintf(buf, "%u\n", value);
 }
 
-/*
+/**
  * ixgbe_add_hwmon_attr - Create hwmon attr table for a hwmon sysfs file.
- * @ adapter: pointer to the adapter structure
- * @ offset: offset in the eeprom sensor data table
- * @ type: type of sensor data to display
+ * @adapter: pointer to the adapter structure
+ * @offset: offset in the eeprom sensor data table
+ * @type: type of sensor data to display
  *
  * For each file we want in hwmon's sysfs interface we need a device_attribute
  * This is included in our hwmon_attr struct that contains the references to
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f69ec42..0368160 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -115,7 +115,7 @@ static inline void ixgbevf_release_rx_desc(struct ixgbe_hw *hw,
 	IXGBE_WRITE_REG(hw, IXGBE_VFRDT(rx_ring->reg_idx), val);
 }
 
-/*
+/**
  * ixgbevf_set_ivar - set IVAR registers - maps interrupt causes to vectors
  * @adapter: pointer to adapter struct
  * @direction: 0 for Rx, 1 for Tx, -1 for other causes
@@ -1942,8 +1942,8 @@ static void ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
 	}
 }
 
-/*
- * ixgbevf_set_num_queues: Allocate queues for device, feature dependent
+/**
+ * ixgbevf_set_num_queues - Allocate queues for device, feature dependent
  * @adapter: board private structure to initialize
  *
  * This is the top level queue allocation routine.  The order here is very
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 875dd5e..76bf159 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1103,7 +1103,7 @@ static void ks_set_grpaddr(struct ks_net *ks)
 	}
 }  /* ks_set_grpaddr */
 
-/*
+/**
 * ks_clear_mcast - clear multicast information
 *
 * @ks : The chip information
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index eaf9ff0..24a4c57 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -3913,7 +3913,7 @@ static void hw_start_rx(struct ksz_hw *hw)
 		hw->rx_stop = 2;
 }
 
-/*
+/**
  * hw_stop_rx - stop receiving
  * @hw: 	The hardware instance.
  *
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index e7cd587..d958c22 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -3377,7 +3377,7 @@ static int wait_for_cmd_complete(void __iomem *addr, u64 busy_bit,
 	} while (cnt < 20);
 	return ret;
 }
-/*
+/**
  * check_pci_device_id - Checks if the device id is supported
  * @id : device id
  * Description: Function to check if the pci device id is supported by driver.
@@ -5238,7 +5238,7 @@ static u64 do_s2io_read_unicast_mc(struct s2io_nic *sp, int offset)
 }
 
 /**
- * s2io_set_mac_addr driver entry point
+ * s2io_set_mac_addr - driver entry point
  */
 
 static int s2io_set_mac_addr(struct net_device *dev, void *p)
@@ -6088,7 +6088,7 @@ static int s2io_bist_test(struct s2io_nic *sp, uint64_t *data)
 }
 
 /**
- * s2io-link_test - verifies the link state of the nic
+ * s2io_link_test - verifies the link state of the nic
  * @sp ; private member of the device structure, which is a pointer to the
  * s2io_nic structure.
  * @data: variable that returns the result of each of the test conducted by
@@ -6116,9 +6116,9 @@ static int s2io_link_test(struct s2io_nic *sp, uint64_t *data)
 
 /**
  * s2io_rldram_test - offline test for access to the RldRam chip on the NIC
- * @sp - private member of the device structure, which is a pointer to the
+ * @sp: private member of the device structure, which is a pointer to the
  * s2io_nic structure.
- * @data - variable that returns the result of each of the test
+ * @data: variable that returns the result of each of the test
  * conducted by the driver.
  * Description:
  *  This is one of the offline test that tests the read and write
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 928913c..c503fbe 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3218,7 +3218,7 @@ static void nv_force_linkspeed(struct net_device *dev, int speed, int duplex)
 }
 
 /**
- * nv_update_linkspeed: Setup the MAC according to the link partner
+ * nv_update_linkspeed - Setup the MAC according to the link partner
  * @dev: Network device to be configured
  *
  * The function queries the PHY and checks if there is a link partner.
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
index e48f084..5ae03e8 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
@@ -60,7 +60,7 @@ static void pch_gbe_plat_get_bus_info(struct pch_gbe_hw *hw)
 /**
  * pch_gbe_plat_init_hw - Initialize hardware
  * @hw:	Pointer to the HW structure
- * Returns
+ * Returns:
  *	0:		Successfully
  *	Negative value:	Failed-EBUSY
  */
@@ -108,7 +108,7 @@ static void pch_gbe_plat_init_function_pointers(struct pch_gbe_hw *hw)
 /**
  * pch_gbe_hal_setup_init_funcs - Initializes function pointers
  * @hw:	Pointer to the HW structure
- * Returns
+ * Returns:
  *	0:	Successfully
  *	ENOSYS:	Function is not registered
  */
@@ -137,7 +137,7 @@ inline void pch_gbe_hal_get_bus_info(struct pch_gbe_hw *hw)
 /**
  * pch_gbe_hal_init_hw - Initialize hardware
  * @hw:	Pointer to the HW structure
- * Returns
+ * Returns:
  *	0:	Successfully
  *	ENOSYS:	Function is not registered
  */
@@ -155,7 +155,7 @@ inline s32 pch_gbe_hal_init_hw(struct pch_gbe_hw *hw)
  * @hw:	    Pointer to the HW structure
  * @offset: The register to read
  * @data:   The buffer to store the 16-bit read.
- * Returns
+ * Returns:
  *	0:	Successfully
  *	Negative value:	Failed
  */
@@ -172,7 +172,7 @@ inline s32 pch_gbe_hal_read_phy_reg(struct pch_gbe_hw *hw, u32 offset,
  * @hw:	    Pointer to the HW structure
  * @offset: The register to read
  * @data:   The value to write.
- * Returns
+ * Returns:
  *	0:	Successfully
  *	Negative value:	Failed
  */
@@ -211,7 +211,7 @@ inline void pch_gbe_hal_phy_sw_reset(struct pch_gbe_hw *hw)
 /**
  * pch_gbe_hal_read_mac_addr - Reads MAC address
  * @hw:	Pointer to the HW structure
- * Returns
+ * Returns:
  *	0:	Successfully
  *	ENOSYS:	Function is not registered
  */
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index ac4e72d..9dbf38c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -77,7 +77,7 @@ static const struct pch_gbe_stats pch_gbe_gstrings_stats[] = {
  * pch_gbe_get_settings - Get device-specific settings
  * @netdev: Network interface device structure
  * @ecmd:   Ethtool command
- * Returns
+ * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
@@ -100,7 +100,7 @@ static int pch_gbe_get_settings(struct net_device *netdev,
  * pch_gbe_set_settings - Set device-specific settings
  * @netdev: Network interface device structure
  * @ecmd:   Ethtool command
- * Returns
+ * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
@@ -220,7 +220,7 @@ static void pch_gbe_get_wol(struct net_device *netdev,
  * pch_gbe_set_wol - Turn Wake-on-Lan on or off
  * @netdev: Network interface device structure
  * @wol:    Pointer of wake-on-Lan information straucture
- * Returns
+ * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
@@ -248,7 +248,7 @@ static int pch_gbe_set_wol(struct net_device *netdev,
 /**
  * pch_gbe_nway_reset - Restart autonegotiation
  * @netdev: Network interface device structure
- * Returns
+ * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
@@ -398,7 +398,7 @@ static void pch_gbe_get_pauseparam(struct net_device *netdev,
  * pch_gbe_set_pauseparam - Set pause paramters
  * @netdev:  Network interface device structure
  * @pause:   Pause parameters structure
- * Returns
+ * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3787c64..b100656 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -301,7 +301,7 @@ inline void pch_gbe_mac_load_mac_addr(struct pch_gbe_hw *hw)
 /**
  * pch_gbe_mac_read_mac_addr - Read MAC address
  * @hw:	            Pointer to the HW structure
- * Returns
+ * Returns:
  *	0:			Successful.
  */
 s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
@@ -483,7 +483,7 @@ static void pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
 /**
  * pch_gbe_mac_force_mac_fc - Force the MAC's flow control settings
  * @hw:	            Pointer to the HW structure
- * Returns
+ * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
@@ -639,7 +639,7 @@ static void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
 /**
  * pch_gbe_alloc_queues - Allocate memory for all rings
  * @adapter:  Board private structure to initialize
- * Returns
+ * Returns:
  *	0:	Successfully
  *	Negative value:	Failed
  */
@@ -670,7 +670,7 @@ static void pch_gbe_init_stats(struct pch_gbe_adapter *adapter)
 /**
  * pch_gbe_init_phy - Initialize PHY
  * @adapter:  Board private structure to initialize
- * Returns
+ * Returns:
  *	0:	Successfully
  *	Negative value:	Failed
  */
@@ -720,7 +720,7 @@ static int pch_gbe_init_phy(struct pch_gbe_adapter *adapter)
  * @netdev: Network interface device structure
  * @addr:   Phy ID
  * @reg:    Access location
- * Returns
+ * Returns:
  *	0:	Successfully
  *	Negative value:	Failed
  */
@@ -1364,7 +1364,7 @@ static void pch_gbe_start_receive(struct pch_gbe_hw *hw)
  * pch_gbe_intr - Interrupt Handler
  * @irq:   Interrupt number
  * @data:  Pointer to a network interface device structure
- * Returns
+ * Returns:
  *	- IRQ_HANDLED:	Our interrupt
  *	- IRQ_NONE:	Not our interrupt
  */
@@ -1566,7 +1566,7 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
  * pch_gbe_clean_tx - Reclaim resources after transmit completes
  * @adapter:   Board private structure
  * @tx_ring:   Tx descriptor ring
- * Returns
+ * Returns:
  *	true:  Cleaned the descriptor
  *	false: Not cleaned the descriptor
  */
@@ -1660,7 +1660,7 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
  * @rx_ring:     Rx descriptor ring
  * @work_done:   Completed count
  * @work_to_do:  Request count
- * Returns
+ * Returns:
  *	true:  Cleaned the descriptor
  *	false: Not cleaned the descriptor
  */
@@ -1775,7 +1775,7 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
  * pch_gbe_setup_tx_resources - Allocate Tx resources (Descriptors)
  * @adapter:  Board private structure
  * @tx_ring:  Tx descriptor ring (for a specific queue) to setup
- * Returns
+ * Returns:
  *	0:		Successfully
  *	Negative value:	Failed
  */
@@ -1822,7 +1822,7 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
  * pch_gbe_setup_rx_resources - Allocate Rx resources (Descriptors)
  * @adapter:  Board private structure
  * @rx_ring:  Rx descriptor ring (for a specific queue) to setup
- * Returns
+ * Returns:
  *	0:		Successfully
  *	Negative value:	Failed
  */
@@ -1899,7 +1899,7 @@ void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
 /**
  * pch_gbe_request_irq - Allocate an interrupt line
  * @adapter:  Board private structure
- * Returns
+ * Returns:
  *	0:		Successfully
  *	Negative value:	Failed
  */
@@ -1932,7 +1932,7 @@ static int pch_gbe_request_irq(struct pch_gbe_adapter *adapter)
 /**
  * pch_gbe_up - Up GbE network device
  * @adapter:  Board private structure
- * Returns
+ * Returns:
  *	0:		Successfully
  *	Negative value:	Failed
  */
@@ -2018,7 +2018,7 @@ void pch_gbe_down(struct pch_gbe_adapter *adapter)
 /**
  * pch_gbe_sw_init - Initialize general software structures (struct pch_gbe_adapter)
  * @adapter:  Board private structure to initialize
- * Returns
+ * Returns:
  *	0:		Successfully
  *	Negative value:	Failed
  */
@@ -2057,7 +2057,7 @@ static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter)
 /**
  * pch_gbe_open - Called when a network interface is made active
  * @netdev:	Network interface device structure
- * Returns
+ * Returns:
  *	0:		Successfully
  *	Negative value:	Failed
  */
@@ -2097,7 +2097,7 @@ err_setup_tx:
 /**
  * pch_gbe_stop - Disables a network interface
  * @netdev:  Network interface device structure
- * Returns
+ * Returns:
  *	0: Successfully
  */
 static int pch_gbe_stop(struct net_device *netdev)
@@ -2117,7 +2117,7 @@ static int pch_gbe_stop(struct net_device *netdev)
  * pch_gbe_xmit_frame - Packet transmitting start
  * @skb:     Socket buffer structure
  * @netdev:  Network interface device structure
- * Returns
+ * Returns:
  *	- NETDEV_TX_OK:   Normal end
  *	- NETDEV_TX_BUSY: Error end
  */
@@ -2225,7 +2225,7 @@ static void pch_gbe_set_multi(struct net_device *netdev)
  * pch_gbe_set_mac - Change the Ethernet Address of the NIC
  * @netdev: Network interface device structure
  * @addr:   Pointer to an address structure
- * Returns
+ * Returns:
  *	0:		Successfully
  *	-EADDRNOTAVAIL:	Failed
  */
@@ -2256,7 +2256,7 @@ static int pch_gbe_set_mac(struct net_device *netdev, void *addr)
  * pch_gbe_change_mtu - Change the Maximum Transfer Unit
  * @netdev:   Network interface device structure
  * @new_mtu:  New value for maximum frame size
- * Returns
+ * Returns:
  *	0:		Successfully
  *	-EINVAL:	Failed
  */
@@ -2309,7 +2309,7 @@ static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu)
  * pch_gbe_set_features - Reset device after features changed
  * @netdev:   Network interface device structure
  * @features:  New features
- * Returns
+ * Returns:
  *	0:		HW state updated successfully
  */
 static int pch_gbe_set_features(struct net_device *netdev,
@@ -2334,7 +2334,7 @@ static int pch_gbe_set_features(struct net_device *netdev,
  * @netdev:   Network interface device structure
  * @ifr:      Pointer to ifr structure
  * @cmd:      Control command
- * Returns
+ * Returns:
  *	0:	Successfully
  *	Negative value:	Failed
  */
@@ -2369,7 +2369,7 @@ static void pch_gbe_tx_timeout(struct net_device *netdev)
  * pch_gbe_napi_poll - NAPI receive and transfer polling callback
  * @napi:    Pointer of polling device struct
  * @budget:  The maximum number of a packet
- * Returns
+ * Returns:
  *	false:  Exit the polling mode
  *	true:   Continue the polling mode
  */
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
index 29e23be..8653c3b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_param.c
@@ -139,7 +139,7 @@ MODULE_PARM_DESC(XsumTX, "Disable or enable Transmit Checksum offload");
 /**
  * pch_gbe_option - Force the MAC's flow control settings
  * @hw:	            Pointer to the HW structure
- * Returns
+ * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
@@ -220,7 +220,7 @@ static const struct pch_gbe_opt_list fc_list[] = {
  * @value:    value
  * @opt:      option
  * @adapter:  Board private structure
- * Returns
+ * Returns:
  *	0:			Successful.
  *	Negative value:		Failed.
  */
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0e57535..a1965c0 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -527,7 +527,7 @@ struct efx_phy_operations {
 };
 
 /**
- * @enum efx_phy_mode - PHY operating mode flags
+ * enum efx_phy_mode - PHY operating mode flags
  * @PHY_MODE_NORMAL: on and should pass traffic
  * @PHY_MODE_TX_DISABLED: on with TX disabled
  * @PHY_MODE_LOW_POWER: set to low power through MDIO
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 243e91f..fca61fe 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -336,6 +336,7 @@ static void efx_recycle_rx_buffer(struct efx_channel *channel,
 /**
  * efx_fast_push_rx_descriptors - push new RX descriptors quickly
  * @rx_queue:		RX descriptor queue
+ *
  * This will aim to fill the RX descriptor queue up to
  * @rx_queue->@max_fill. If there is insufficient atomic
  * memory to do so, a slow fill will be scheduled.
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 8814b2f..8d15f7a 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -773,7 +773,7 @@ static int smc911x_phy_fixed(struct net_device *dev)
 	return 1;
 }
 
-/*
+/**
  * smc911x_phy_reset - reset the phy
  * @dev: net device
  * @phy: phy address
@@ -819,7 +819,7 @@ static int smc911x_phy_reset(struct net_device *dev, int phy)
 	return reg & PMT_CTRL_PHY_RST_;
 }
 
-/*
+/**
  * smc911x_phy_powerdown - powerdown phy
  * @dev: net device
  * @phy: phy address
@@ -837,7 +837,7 @@ static void smc911x_phy_powerdown(struct net_device *dev, int phy)
 	SMC_SET_PHY_BMCR(lp, phy, bmcr);
 }
 
-/*
+/**
  * smc911x_phy_check_media - check the media status and adjust BMCR
  * @dev: net device
  * @init: set true for initialisation
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index fee4493..318adc9 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -942,7 +942,7 @@ static int smc_phy_fixed(struct net_device *dev)
 	return 1;
 }
 
-/*
+/**
  * smc_phy_reset - reset the phy
  * @dev: net device
  * @phy: phy address
@@ -976,7 +976,7 @@ static int smc_phy_reset(struct net_device *dev, int phy)
 	return bmcr & BMCR_RESET;
 }
 
-/*
+/**
  * smc_phy_powerdown - powerdown phy
  * @dev: net device
  *
@@ -1000,7 +1000,7 @@ static void smc_phy_powerdown(struct net_device *dev)
 	smc_phy_write(dev, phy, MII_BMCR, bmcr | BMCR_PDOWN);
 }
 
-/*
+/**
  * smc_phy_check_media - check the media status and adjust TCR
  * @dev: net device
  * @init: set true for initialisation
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index cf826e6..13afb8e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -125,7 +125,7 @@ err_out_req_reg_failed:
 }
 
 /**
- * stmmac_dvr_remove
+ * stmmac_pci_remove
  *
  * @pdev: platform device pointer
  * Description: this function calls the main to free the net resources
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 447a693..6ce9edd 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -137,14 +137,15 @@ static void print_eth_id(struct net_device *ndev)
 #define bdx_disable_interrupts(priv)	\
 	do { WRITE_REG(priv, regIMR, 0); } while (0)
 
-/* bdx_fifo_init
- * create TX/RX descriptor fifo for host-NIC communication.
+/**
+ * bdx_fifo_init - create TX/RX descriptor fifo for host-NIC communication.
+ * @priv: NIC private structure
+ * @f: fifo to initialize
+ * @fsz_type: fifo size type: 0-4KB, 1-8KB, 2-16KB, 3-32KB
+ * @reg_XXX: offsets of registers relative to base address
+ *
  * 1K extra space is allocated at the end of the fifo to simplify
  * processing of descriptors that wraps around fifo's end
- * @priv - NIC private structure
- * @f - fifo to initialize
- * @fsz_type - fifo size type: 0-4KB, 1-8KB, 2-16KB, 3-32KB
- * @reg_XXX - offsets of registers relative to base address
  *
  * Returns 0 on success, negative value on failure
  *
@@ -177,9 +178,10 @@ bdx_fifo_init(struct bdx_priv *priv, struct fifo *f, int fsz_type,
 	RET(0);
 }
 
-/* bdx_fifo_free - free all resources used by fifo
- * @priv - NIC private structure
- * @f - fifo to release
+/**
+ * bdx_fifo_free - free all resources used by fifo
+ * @priv: NIC private structure
+ * @f: fifo to release
  */
 static void bdx_fifo_free(struct bdx_priv *priv, struct fifo *f)
 {
@@ -192,9 +194,9 @@ static void bdx_fifo_free(struct bdx_priv *priv, struct fifo *f)
 	RET();
 }
 
-/*
+/**
  * bdx_link_changed - notifies OS about hw link state.
- * @bdx_priv - hw adapter structure
+ * @priv: hw adapter structure
  */
 static void bdx_link_changed(struct bdx_priv *priv)
 {
@@ -233,10 +235,10 @@ static void bdx_isr_extra(struct bdx_priv *priv, u32 isr)
 
 }
 
-/* bdx_isr - Interrupt Service Routine for Bordeaux NIC
- * @irq - interrupt number
- * @ndev - network device
- * @regs - CPU registers
+/**
+ * bdx_isr_napi - Interrupt Service Routine for Bordeaux NIC
+ * @irq: interrupt number
+ * @dev: network device
  *
  * Return IRQ_NONE if it was not our interrupt, IRQ_HANDLED - otherwise
  *
@@ -307,8 +309,10 @@ static int bdx_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-/* bdx_fw_load - loads firmware to NIC
- * @priv - NIC private structure
+/**
+ * bdx_fw_load - loads firmware to NIC
+ * @priv: NIC private structure
+ *
  * Firmware is loaded via TXD fifo, so it must be initialized first.
  * Firware must be loaded once per NIC not per PCI device provided by NIC (NIC
  * can have few of them). So all drivers use semaphore register to choose one
@@ -380,8 +384,9 @@ static void bdx_restore_mac(struct net_device *ndev, struct bdx_priv *priv)
 	RET();
 }
 
-/* bdx_hw_start - inits registers and starts HW's Rx and Tx engines
- * @priv - NIC private structure
+/**
+ * bdx_hw_start - inits registers and starts HW's Rx and Tx engines
+ * @priv: NIC private structure
  */
 static int bdx_hw_start(struct bdx_priv *priv)
 {
@@ -691,12 +696,13 @@ static int bdx_ioctl(struct net_device *ndev, struct ifreq *ifr, int cmd)
 		RET(-EOPNOTSUPP);
 }
 
-/*
+/**
  * __bdx_vlan_rx_vid - private helper for adding/killing VLAN vid
- *                     by passing VLAN filter table to hardware
- * @ndev network device
- * @vid  VLAN vid
- * @op   add or kill operation
+ * @ndev: network device
+ * @vid:  VLAN vid
+ * @op:   add or kill operation
+ *
+ * Passes VLAN filter table to hardware
  */
 static void __bdx_vlan_rx_vid(struct net_device *ndev, uint16_t vid, int enable)
 {
@@ -722,10 +728,10 @@ static void __bdx_vlan_rx_vid(struct net_device *ndev, uint16_t vid, int enable)
 	RET();
 }
 
-/*
+/**
  * bdx_vlan_rx_add_vid - kernel hook for adding VLAN vid to hw filtering table
- * @ndev network device
- * @vid  VLAN vid to add
+ * @ndev: network device
+ * @vid:  VLAN vid to add
  */
 static int bdx_vlan_rx_add_vid(struct net_device *ndev, uint16_t vid)
 {
@@ -733,10 +739,10 @@ static int bdx_vlan_rx_add_vid(struct net_device *ndev, uint16_t vid)
 	return 0;
 }
 
-/*
+/**
  * bdx_vlan_rx_kill_vid - kernel hook for killing VLAN vid in hw filtering table
- * @ndev network device
- * @vid  VLAN vid to kill
+ * @ndev: network device
+ * @vid:  VLAN vid to kill
  */
 static int bdx_vlan_rx_kill_vid(struct net_device *ndev, unsigned short vid)
 {
@@ -974,8 +980,9 @@ static inline void bdx_rxdb_free_elem(struct rxdb *db, int n)
  *     Rx Init                                                           *
  *************************************************************************/
 
-/* bdx_rx_init - initialize RX all related HW and SW resources
- * @priv - NIC private structure
+/**
+ * bdx_rx_init - initialize RX all related HW and SW resources
+ * @priv: NIC private structure
  *
  * Returns 0 on success, negative value on failure
  *
@@ -1016,9 +1023,10 @@ err_mem:
 	return -ENOMEM;
 }
 
-/* bdx_rx_free_skbs - frees and unmaps all skbs allocated for the fifo
- * @priv - NIC private structure
- * @f - RXF fifo
+/**
+ * bdx_rx_free_skbs - frees and unmaps all skbs allocated for the fifo
+ * @priv: NIC private structure
+ * @f: RXF fifo
  */
 static void bdx_rx_free_skbs(struct bdx_priv *priv, struct rxf_fifo *f)
 {
@@ -1045,8 +1053,10 @@ static void bdx_rx_free_skbs(struct bdx_priv *priv, struct rxf_fifo *f)
 	}
 }
 
-/* bdx_rx_free - release all Rx resources
- * @priv - NIC private structure
+/**
+ * bdx_rx_free - release all Rx resources
+ * @priv: NIC private structure
+ *
  * It assumes that Rx is desabled in HW
  */
 static void bdx_rx_free(struct bdx_priv *priv)
@@ -1067,9 +1077,11 @@ static void bdx_rx_free(struct bdx_priv *priv)
  *     Rx Engine                                                         *
  *************************************************************************/
 
-/* bdx_rx_alloc_skbs - fill rxf fifo with new skbs
- * @priv - nic's private structure
- * @f - RXF fifo that needs skbs
+/**
+ * bdx_rx_alloc_skbs - fill rxf fifo with new skbs
+ * @priv: nic's private structure
+ * @f: RXF fifo that needs skbs
+ *
  * It allocates skbs, build rxf descs and push it (rxf descr) into rxf fifo.
  * skb's virtual and physical addresses are stored in skb db.
  * To calculate free space, func uses cached values of RPTR and WPTR
@@ -1179,13 +1191,15 @@ static void bdx_recycle_skb(struct bdx_priv *priv, struct rxd_desc *rxdd)
 	RET();
 }
 
-/* bdx_rx_receive - receives full packets from RXD fifo and pass them to OS
+/**
+ * bdx_rx_receive - receives full packets from RXD fifo and pass them to OS
  * NOTE: a special treatment is given to non-continuous descriptors
  * that start near the end, wraps around and continue at the beginning. a second
  * part is copied right after the first, and then descriptor is interpreted as
  * normal. fifo has an extra space to allow such operations
- * @priv - nic's private structure
- * @f - RXF fifo that needs skbs
+ * @priv: nic's private structure
+ * @f: RXF fifo that needs skbs
+ * @budget: maximum number of packets to receive
  */
 
 /* TBD: replace memcpy func call by explicite inline asm */
@@ -1375,9 +1389,10 @@ static inline int bdx_tx_db_size(struct txdb *db)
 	return db->size - taken;
 }
 
-/* __bdx_tx_ptr_next - helper function, increment read/write pointer + wrap
- * @d   - tx data base
- * @ptr - read or write pointer
+/**
+ * __bdx_tx_db_ptr_next - helper function, increment read/write pointer + wrap
+ * @db: tx data base
+ * @pptr: read or write pointer
  */
 static inline void __bdx_tx_db_ptr_next(struct txdb *db, struct tx_map **pptr)
 {
@@ -1394,8 +1409,9 @@ static inline void __bdx_tx_db_ptr_next(struct txdb *db, struct tx_map **pptr)
 		*pptr = db->start;
 }
 
-/* bdx_tx_db_inc_rptr - increment read pointer
- * @d   - tx data base
+/**
+ * bdx_tx_db_inc_rptr - increment read pointer
+ * @db: tx data base
  */
 static inline void bdx_tx_db_inc_rptr(struct txdb *db)
 {
@@ -1403,8 +1419,9 @@ static inline void bdx_tx_db_inc_rptr(struct txdb *db)
 	__bdx_tx_db_ptr_next(db, &db->rptr);
 }
 
-/* bdx_tx_db_inc_rptr - increment write pointer
- * @d   - tx data base
+/**
+ * bdx_tx_db_inc_wptr - increment write pointer
+ * @db: tx data base
  */
 static inline void bdx_tx_db_inc_wptr(struct txdb *db)
 {
@@ -1413,9 +1430,11 @@ static inline void bdx_tx_db_inc_wptr(struct txdb *db)
 						   a result of write */
 }
 
-/* bdx_tx_db_init - creates and initializes tx db
- * @d       - tx data base
- * @sz_type - size of tx fifo
+/**
+ * bdx_tx_db_init - creates and initializes tx db
+ * @d: tx data base
+ * @sz_type: size of tx fifo
+ *
  * Returns 0 on success, error code otherwise
  */
 static int bdx_tx_db_init(struct txdb *d, int sz_type)
@@ -1441,8 +1460,9 @@ static int bdx_tx_db_init(struct txdb *d, int sz_type)
 	return 0;
 }
 
-/* bdx_tx_db_close - closes tx db and frees all memory
- * @d - tx data base
+/**
+ * bdx_tx_db_close - closes tx db and frees all memory
+ * @d: tx data base
  */
 static void bdx_tx_db_close(struct txdb *d)
 {
@@ -1463,9 +1483,11 @@ static struct {
 	u16 qwords;		/* qword = 64 bit */
 } txd_sizes[MAX_SKB_FRAGS + 1];
 
-/* txdb_map_skb - creates and stores dma mappings for skb's data blocks
- * @priv - NIC private structure
- * @skb  - socket buffer to map
+/**
+ * bdx_tx_map_skb - creates and stores dma mappings for skb's data blocks
+ * @priv: NIC private structure
+ * @skb: socket buffer to map
+ * @txdd: TX descriptor to use
  *
  * It makes dma mappings for skb's data blocks and writes them to PBL of
  * new tx descriptor. It also stores them in the tx db, so they could be
@@ -1562,9 +1584,10 @@ err_mem:
 	return -ENOMEM;
 }
 
-/*
+/**
  * bdx_tx_space - calculates available space in TX fifo
- * @priv - NIC private structure
+ * @priv: NIC private structure
+ *
  * Returns available space in TX fifo in bytes
  */
 static inline int bdx_tx_space(struct bdx_priv *priv)
@@ -1579,9 +1602,10 @@ static inline int bdx_tx_space(struct bdx_priv *priv)
 	return fsize;
 }
 
-/* bdx_tx_transmit - send packet to NIC
- * @skb - packet to send
- * ndev - network device assigned to NIC
+/**
+ * bdx_tx_transmit - send packet to NIC
+ * @skb: packet to send
+ * @ndev: network device assigned to NIC
  * Return codes:
  * o NETDEV_TX_OK everything ok.
  * o NETDEV_TX_BUSY Cannot transmit packet, try later
@@ -1699,8 +1723,10 @@ static netdev_tx_t bdx_tx_transmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-/* bdx_tx_cleanup - clean TXF fifo, run in the context of IRQ.
- * @priv - bdx adapter
+/**
+ * bdx_tx_cleanup - clean TXF fifo, run in the context of IRQ.
+ * @priv: bdx adapter
+ *
  * It scans TXF fifo for descriptors, frees DMA mappings and reports to OS
  * that those packets were sent
  */
@@ -1761,7 +1787,8 @@ static void bdx_tx_cleanup(struct bdx_priv *priv)
 	spin_unlock(&priv->tx_lock);
 }
 
-/* bdx_tx_free_skbs - frees all skbs from TXD fifo.
+/**
+ * bdx_tx_free_skbs - frees all skbs from TXD fifo.
  * It gets called when OS stops this dev, eg upon "ifconfig down" or rmmod
  */
 static void bdx_tx_free_skbs(struct bdx_priv *priv)
@@ -1790,10 +1817,11 @@ static void bdx_tx_free(struct bdx_priv *priv)
 	bdx_tx_db_close(&priv->txdb);
 }
 
-/* bdx_tx_push_desc - push descriptor to TxD fifo
- * @priv - NIC private structure
- * @data - desc's data
- * @size - desc's size
+/**
+ * bdx_tx_push_desc - push descriptor to TxD fifo
+ * @priv: NIC private structure
+ * @data: desc's data
+ * @size: desc's size
  *
  * Pushes desc to TxD fifo and overlaps it if needed.
  * NOTE: this func does not check for available space. this is responsibility
@@ -1819,10 +1847,11 @@ static void bdx_tx_push_desc(struct bdx_priv *priv, void *data, int size)
 	WRITE_REG(priv, f->m.reg_WPTR, f->m.wptr & TXF_WPTR_WR_PTR);
 }
 
-/* bdx_tx_push_desc_safe - push descriptor to TxD fifo in a safe way
- * @priv - NIC private structure
- * @data - desc's data
- * @size - desc's size
+/**
+ * bdx_tx_push_desc_safe - push descriptor to TxD fifo in a safe way
+ * @priv: NIC private structure
+ * @data: desc's data
+ * @size: desc's size
  *
  * NOTE: this func does check for available space and, if necessary, waits for
  *   NIC to read existing data before writing new one.
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 4da93a5..9cdd619 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -375,7 +375,7 @@ static char *emac_rxhost_errcodes[16] = {
 #define emac_ctrl_write(reg, val) iowrite32(val, (priv->ctrl_base + (reg)))
 
 /**
- * emac_dump_regs: Dump important EMAC registers to debug terminal
+ * emac_dump_regs - Dump important EMAC registers to debug terminal
  * @priv: The DaVinci EMAC private adapter structure
  *
  * Executes ethtool set cmd & sets phy mode
@@ -466,7 +466,7 @@ static void emac_dump_regs(struct emac_priv *priv)
 }
 
 /**
- * emac_get_drvinfo: Get EMAC driver information
+ * emac_get_drvinfo - Get EMAC driver information
  * @ndev: The DaVinci EMAC network adapter
  * @info: ethtool info structure containing name and version
  *
@@ -481,7 +481,7 @@ static void emac_get_drvinfo(struct net_device *ndev,
 }
 
 /**
- * emac_get_settings: Get EMAC settings
+ * emac_get_settings - Get EMAC settings
  * @ndev: The DaVinci EMAC network adapter
  * @ecmd: ethtool command
  *
@@ -500,7 +500,7 @@ static int emac_get_settings(struct net_device *ndev,
 }
 
 /**
- * emac_set_settings: Set EMAC settings
+ * emac_set_settings - Set EMAC settings
  * @ndev: The DaVinci EMAC network adapter
  * @ecmd: ethtool command
  *
@@ -518,7 +518,7 @@ static int emac_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
 }
 
 /**
- * emac_get_coalesce : Get interrupt coalesce settings for this device
+ * emac_get_coalesce - Get interrupt coalesce settings for this device
  * @ndev : The DaVinci EMAC network adapter
  * @coal : ethtool coalesce settings structure
  *
@@ -536,7 +536,7 @@ static int emac_get_coalesce(struct net_device *ndev,
 }
 
 /**
- * emac_set_coalesce : Set interrupt coalesce settings for this device
+ * emac_set_coalesce - Set interrupt coalesce settings for this device
  * @ndev : The DaVinci EMAC network adapter
  * @coal : ethtool coalesce settings structure
  *
@@ -631,7 +631,7 @@ static const struct ethtool_ops ethtool_ops = {
 };
 
 /**
- * emac_update_phystatus: Update Phy status
+ * emac_update_phystatus - Update Phy status
  * @priv: The DaVinci EMAC private adapter structure
  *
  * Updates phy status and takes action for network queue if required
@@ -697,7 +697,7 @@ static void emac_update_phystatus(struct emac_priv *priv)
 }
 
 /**
- * hash_get: Calculate hash value from mac address
+ * hash_get - Calculate hash value from mac address
  * @addr: mac address to delete from hash table
  *
  * Calculates hash value from mac address
@@ -723,9 +723,9 @@ static u32 hash_get(u8 *addr)
 }
 
 /**
- * hash_add: Hash function to add mac addr from hash table
+ * hash_add - Hash function to add mac addr from hash table
  * @priv: The DaVinci EMAC private adapter structure
- * mac_addr: mac address to delete from hash table
+ * @mac_addr: mac address to delete from hash table
  *
  * Adds mac address to the internal hash table
  *
@@ -765,9 +765,9 @@ static int hash_add(struct emac_priv *priv, u8 *mac_addr)
 }
 
 /**
- * hash_del: Hash function to delete mac addr from hash table
+ * hash_del - Hash function to delete mac addr from hash table
  * @priv: The DaVinci EMAC private adapter structure
- * mac_addr: mac address to delete from hash table
+ * @mac_addr: mac address to delete from hash table
  *
  * Removes mac address from the internal hash table
  *
@@ -807,7 +807,7 @@ static int hash_del(struct emac_priv *priv, u8 *mac_addr)
 #define EMAC_ALL_MULTI_CLR	3
 
 /**
- * emac_add_mcast: Set multicast address in the EMAC adapter (Internal)
+ * emac_add_mcast - Set multicast address in the EMAC adapter (Internal)
  * @priv: The DaVinci EMAC private adapter structure
  * @action: multicast operation to perform
  * mac_addr: mac address to set
@@ -855,7 +855,7 @@ static void emac_add_mcast(struct emac_priv *priv, u32 action, u8 *mac_addr)
 }
 
 /**
- * emac_dev_mcast_set: Set multicast address in the EMAC adapter
+ * emac_dev_mcast_set - Set multicast address in the EMAC adapter
  * @ndev: The DaVinci EMAC network adapter
  *
  * Set multicast addresses in EMAC adapter
@@ -901,7 +901,7 @@ static void emac_dev_mcast_set(struct net_device *ndev)
  *************************************************************************/
 
 /**
- * emac_int_disable: Disable EMAC module interrupt (from adapter)
+ * emac_int_disable - Disable EMAC module interrupt (from adapter)
  * @priv: The DaVinci EMAC private adapter structure
  *
  * Disable EMAC interrupt on the adapter
@@ -931,7 +931,7 @@ static void emac_int_disable(struct emac_priv *priv)
 }
 
 /**
- * emac_int_enable: Enable EMAC module interrupt (from adapter)
+ * emac_int_enable - Enable EMAC module interrupt (from adapter)
  * @priv: The DaVinci EMAC private adapter structure
  *
  * Enable EMAC interrupt on the adapter
@@ -967,7 +967,7 @@ static void emac_int_enable(struct emac_priv *priv)
 }
 
 /**
- * emac_irq: EMAC interrupt handler
+ * emac_irq - EMAC interrupt handler
  * @irq: interrupt number
  * @dev_id: EMAC network adapter data structure ptr
  *
@@ -1060,7 +1060,7 @@ static void emac_tx_handler(void *token, int len, int status)
 }
 
 /**
- * emac_dev_xmit: EMAC Transmit function
+ * emac_dev_xmit - EMAC Transmit function
  * @skb: SKB pointer
  * @ndev: The DaVinci EMAC network adapter
  *
@@ -1111,7 +1111,7 @@ fail_tx:
 }
 
 /**
- * emac_dev_tx_timeout: EMAC Transmit timeout function
+ * emac_dev_tx_timeout - EMAC Transmit timeout function
  * @ndev: The DaVinci EMAC network adapter
  *
  * Called when system detects that a skb timeout period has expired
@@ -1138,7 +1138,7 @@ static void emac_dev_tx_timeout(struct net_device *ndev)
 }
 
 /**
- * emac_set_type0addr: Set EMAC Type0 mac address
+ * emac_set_type0addr - Set EMAC Type0 mac address
  * @priv: The DaVinci EMAC private adapter structure
  * @ch: RX channel number
  * @mac_addr: MAC address to set in device
@@ -1165,7 +1165,7 @@ static void emac_set_type0addr(struct emac_priv *priv, u32 ch, char *mac_addr)
 }
 
 /**
- * emac_set_type1addr: Set EMAC Type1 mac address
+ * emac_set_type1addr - Set EMAC Type1 mac address
  * @priv: The DaVinci EMAC private adapter structure
  * @ch: RX channel number
  * @mac_addr: MAC address to set in device
@@ -1187,7 +1187,7 @@ static void emac_set_type1addr(struct emac_priv *priv, u32 ch, char *mac_addr)
 }
 
 /**
- * emac_set_type2addr: Set EMAC Type2 mac address
+ * emac_set_type2addr - Set EMAC Type2 mac address
  * @priv: The DaVinci EMAC private adapter structure
  * @ch: RX channel number
  * @mac_addr: MAC address to set in device
@@ -1213,7 +1213,7 @@ static void emac_set_type2addr(struct emac_priv *priv, u32 ch,
 }
 
 /**
- * emac_setmac: Set mac address in the adapter (internal function)
+ * emac_setmac - Set mac address in the adapter (internal function)
  * @priv: The DaVinci EMAC private adapter structure
  * @ch: RX channel number
  * @mac_addr: MAC address to set in device
@@ -1242,7 +1242,7 @@ static void emac_setmac(struct emac_priv *priv, u32 ch, char *mac_addr)
 }
 
 /**
- * emac_dev_setmac_addr: Set mac address in the adapter
+ * emac_dev_setmac_addr - Set mac address in the adapter
  * @ndev: The DaVinci EMAC network adapter
  * @addr: MAC address to set in device
  *
@@ -1277,7 +1277,7 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 }
 
 /**
- * emac_hw_enable: Enable EMAC hardware for packet transmission/reception
+ * emac_hw_enable - Enable EMAC hardware for packet transmission/reception
  * @priv: The DaVinci EMAC private adapter structure
  *
  * Enables EMAC hardware for packet processing - enables PHY, enables RX
@@ -1347,7 +1347,7 @@ static int emac_hw_enable(struct emac_priv *priv)
 }
 
 /**
- * emac_poll: EMAC NAPI Poll function
+ * emac_poll - EMAC NAPI Poll function
  * @ndev: The DaVinci EMAC network adapter
  * @budget: Number of receive packets to process (as told by NAPI layer)
  *
@@ -1430,7 +1430,7 @@ static int emac_poll(struct napi_struct *napi, int budget)
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /**
- * emac_poll_controller: EMAC Poll controller function
+ * emac_poll_controller - EMAC Poll controller function
  * @ndev: The DaVinci EMAC network adapter
  *
  * Polled functionality used by netconsole and others in non interrupt mode
@@ -1489,7 +1489,7 @@ static void emac_adjust_link(struct net_device *ndev)
  *************************************************************************/
 
 /**
- * emac_devioctl: EMAC adapter ioctl
+ * emac_devioctl - EMAC adapter ioctl
  * @ndev: The DaVinci EMAC network adapter
  * @ifrq: request parameter
  * @cmd: command parameter
@@ -1516,7 +1516,7 @@ static int match_first_device(struct device *dev, void *data)
 }
 
 /**
- * emac_dev_open: EMAC device open
+ * emac_dev_open - EMAC device open
  * @ndev: The DaVinci EMAC network adapter
  *
  * Called when system wants to start the interface. We init TX/RX channels
@@ -1649,7 +1649,7 @@ rollback:
 }
 
 /**
- * emac_dev_stop: EMAC device stop
+ * emac_dev_stop - EMAC device stop
  * @ndev: The DaVinci EMAC network adapter
  *
  * Called when system wants to stop or down the interface. We stop the network
@@ -1691,7 +1691,7 @@ static int emac_dev_stop(struct net_device *ndev)
 }
 
 /**
- * emac_dev_getnetstats: EMAC get statistics function
+ * emac_dev_getnetstats - EMAC get statistics function
  * @ndev: The DaVinci EMAC network adapter
  *
  * Called when system wants to get statistics from the device.
@@ -1763,7 +1763,7 @@ static const struct net_device_ops emac_netdev_ops = {
 };
 
 /**
- * davinci_emac_probe: EMAC device probe
+ * davinci_emac_probe - EMAC device probe
  * @pdev: The DaVinci EMAC device that we are removing
  *
  * Called when probing for emac devicesr. We get details of instances and
@@ -1949,7 +1949,7 @@ free_clk:
 }
 
 /**
- * davinci_emac_remove: EMAC device remove
+ * davinci_emac_remove - EMAC device remove
  * @pdev: The DaVinci EMAC device that we are removing
  *
  * Called when removing the device driver. We disable clock usage and release
@@ -2029,7 +2029,7 @@ static struct platform_driver davinci_emac_driver = {
 };
 
 /**
- * davinci_emac_init: EMAC driver module init
+ * davinci_emac_init - EMAC driver module init
  *
  * Called when initializing the driver. We register the driver with
  * the platform.
@@ -2041,7 +2041,7 @@ static int __init davinci_emac_init(void)
 late_initcall(davinci_emac_init);
 
 /**
- * davinci_emac_exit: EMAC driver module exit
+ * davinci_emac_exit - EMAC driver module exit
  *
  * Called when exiting the driver completely. We unregister the driver with
  * the platform and exit
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 6199f6b..c1ebfe9 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -114,7 +114,8 @@ spider_net_write_reg(struct spider_net_card *card, u32 reg, u32 value)
 	out_be32(card->regs + reg, value);
 }
 
-/** spider_net_write_phy - write to phy register
+/**
+ * spider_net_write_phy - write to phy register
  * @netdev: adapter to be written to
  * @mii_id: id of MII
  * @reg: PHY register
@@ -137,7 +138,8 @@ spider_net_write_phy(struct net_device *netdev, int mii_id,
 	spider_net_write_reg(card, SPIDER_NET_GPCWOPCMD, writevalue);
 }
 
-/** spider_net_read_phy - read from phy register
+/**
+ * spider_net_read_phy - read from phy register
  * @netdev: network device to be read from
  * @mii_id: id of MII
  * @reg: PHY register
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index 1eaf712..1817d0e 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -197,7 +197,7 @@ static int temac_dcr_setup(struct temac_local *lp, struct platform_device *op,
 #endif
 
 /**
- *  * temac_dma_bd_release - Release buffer descriptor rings
+ * temac_dma_bd_release - Release buffer descriptor rings
  */
 static void temac_dma_bd_release(struct net_device *ndev)
 {
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

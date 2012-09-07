From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/4] netdev: make pci_error_handlers const
Date: Fri, 07 Sep 2012 09:33:15 -0700
Message-ID: <20120907163437.969875699@vyatta.com>
References: <20120907163313.614852012@vyatta.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Linas Vepstas <linasvepstas@gmail.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:35650 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932Ab2IGQpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 12:45:44 -0400
Content-Disposition: inline; filename=pci-errhandle-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Depends on first patch that changes PCI core.

 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c                 |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c     |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                  |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c      |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c          |    2 +-
 drivers/net/ethernet/intel/e100.c                    |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c        |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c           |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c            |    2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c            |    2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c          |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c            |    2 +-
 drivers/net/ethernet/neterion/s2io.c                 |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c       |    2 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |    2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         |    2 +-
 23 files changed, 23 insertions(+), 23 deletions(-)

--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c	2012-09-07 09:27:24.503069260 -0700
@@ -2685,7 +2685,7 @@ static void atl1c_io_resume(struct pci_d
 	netif_device_attach(netdev);
 }
 
-static struct pci_error_handlers atl1c_err_handler = {
+static const struct pci_error_handlers atl1c_err_handler = {
 	.error_detected = atl1c_io_error_detected,
 	.slot_reset = atl1c_io_slot_reset,
 	.resume = atl1c_io_resume,
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c	2012-09-07 09:27:24.503069260 -0700
@@ -2489,7 +2489,7 @@ static void atl1e_io_resume(struct pci_d
 	netif_device_attach(netdev);
 }
 
-static struct pci_error_handlers atl1e_err_handler = {
+static const struct pci_error_handlers atl1e_err_handler = {
 	.error_detected = atl1e_io_error_detected,
 	.slot_reset = atl1e_io_slot_reset,
 	.resume = atl1e_io_resume,
--- a/drivers/net/ethernet/broadcom/bnx2.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/broadcom/bnx2.c	2012-09-07 09:27:24.507069220 -0700
@@ -8742,7 +8742,7 @@ static void bnx2_io_resume(struct pci_de
 	rtnl_unlock();
 }
 
-static struct pci_error_handlers bnx2_err_handler = {
+static const struct pci_error_handlers bnx2_err_handler = {
 	.error_detected	= bnx2_io_error_detected,
 	.slot_reset	= bnx2_io_slot_reset,
 	.resume		= bnx2_io_resume,
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	2012-09-07 09:27:24.511069180 -0700
@@ -12171,7 +12171,7 @@ static void bnx2x_io_resume(struct pci_d
 	rtnl_unlock();
 }
 
-static struct pci_error_handlers bnx2x_err_handler = {
+static const struct pci_error_handlers bnx2x_err_handler = {
 	.error_detected = bnx2x_io_error_detected,
 	.slot_reset     = bnx2x_io_slot_reset,
 	.resume         = bnx2x_io_resume,
--- a/drivers/net/ethernet/broadcom/tg3.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/broadcom/tg3.c	2012-09-07 09:27:24.511069180 -0700
@@ -16397,7 +16397,7 @@ done:
 	rtnl_unlock();
 }
 
-static struct pci_error_handlers tg3_err_handler = {
+static const struct pci_error_handlers tg3_err_handler = {
 	.error_detected	= tg3_io_error_detected,
 	.slot_reset	= tg3_io_slot_reset,
 	.resume		= tg3_io_resume
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c	2012-09-07 09:27:24.515069139 -0700
@@ -3036,7 +3036,7 @@ static void t3_io_resume(struct pci_dev
 	t3_resume_ports(adapter);
 }
 
-static struct pci_error_handlers t3_err_handler = {
+static const struct pci_error_handlers t3_err_handler = {
 	.error_detected = t3_io_error_detected,
 	.slot_reset = t3_io_slot_reset,
 	.resume = t3_io_resume,
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c	2012-09-07 09:27:24.515069139 -0700
@@ -3453,7 +3453,7 @@ static void eeh_resume(struct pci_dev *p
 	rtnl_unlock();
 }
 
-static struct pci_error_handlers cxgb4_eeh = {
+static const struct pci_error_handlers cxgb4_eeh = {
 	.error_detected = eeh_err_detected,
 	.slot_reset     = eeh_slot_reset,
 	.resume         = eeh_resume,
--- a/drivers/net/ethernet/emulex/benet/be_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/emulex/benet/be_main.c	2012-09-07 09:27:24.515069139 -0700
@@ -4104,7 +4104,7 @@ err:
 	dev_err(&adapter->pdev->dev, "EEH resume failed\n");
 }
 
-static struct pci_error_handlers be_eeh_handlers = {
+static const struct pci_error_handlers be_eeh_handlers = {
 	.error_detected = be_eeh_err_detected,
 	.slot_reset = be_eeh_reset,
 	.resume = be_eeh_resume,
--- a/drivers/net/ethernet/intel/e100.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/intel/e100.c	2012-09-07 09:27:24.515069139 -0700
@@ -3157,7 +3157,7 @@ static void e100_io_resume(struct pci_de
 	}
 }
 
-static struct pci_error_handlers e100_err_handler = {
+static const struct pci_error_handlers e100_err_handler = {
 	.error_detected = e100_io_error_detected,
 	.slot_reset = e100_io_slot_reset,
 	.resume = e100_io_resume,
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-09-07 09:27:24.515069139 -0700
@@ -192,7 +192,7 @@ static pci_ers_result_t e1000_io_error_d
 static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev);
 static void e1000_io_resume(struct pci_dev *pdev);
 
-static struct pci_error_handlers e1000_err_handler = {
+static const struct pci_error_handlers e1000_err_handler = {
 	.error_detected = e1000_io_error_detected,
 	.slot_reset = e1000_io_slot_reset,
 	.resume = e1000_io_resume,
--- a/drivers/net/ethernet/intel/e1000e/netdev.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c	2012-09-07 09:27:24.519069099 -0700
@@ -6472,7 +6472,7 @@ static void __devexit e1000_remove(struc
 }
 
 /* PCI Error Recovery (ERS) */
-static struct pci_error_handlers e1000_err_handler = {
+static const struct pci_error_handlers e1000_err_handler = {
 	.error_detected = e1000_io_error_detected,
 	.slot_reset = e1000_io_slot_reset,
 	.resume = e1000_io_resume,
--- a/drivers/net/ethernet/intel/igb/igb_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/intel/igb/igb_main.c	2012-09-07 09:27:24.519069099 -0700
@@ -217,7 +217,7 @@ static pci_ers_result_t igb_io_error_det
 static pci_ers_result_t igb_io_slot_reset(struct pci_dev *);
 static void igb_io_resume(struct pci_dev *);
 
-static struct pci_error_handlers igb_err_handler = {
+static const struct pci_error_handlers igb_err_handler = {
 	.error_detected = igb_io_error_detected,
 	.slot_reset = igb_io_slot_reset,
 	.resume = igb_io_resume,
--- a/drivers/net/ethernet/intel/igbvf/netdev.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c	2012-09-07 09:27:24.519069099 -0700
@@ -2833,7 +2833,7 @@ static void __devexit igbvf_remove(struc
 }
 
 /* PCI Error Recovery (ERS) */
-static struct pci_error_handlers igbvf_err_handler = {
+static const struct pci_error_handlers igbvf_err_handler = {
 	.error_detected = igbvf_io_error_detected,
 	.slot_reset = igbvf_io_slot_reset,
 	.resume = igbvf_io_resume,
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c	2012-09-07 09:27:24.519069099 -0700
@@ -115,7 +115,7 @@ static pci_ers_result_t ixgb_io_error_de
 static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev);
 static void ixgb_io_resume (struct pci_dev *pdev);
 
-static struct pci_error_handlers ixgb_err_handler = {
+static const struct pci_error_handlers ixgb_err_handler = {
 	.error_detected = ixgb_io_error_detected,
 	.slot_reset = ixgb_io_slot_reset,
 	.resume = ixgb_io_resume,
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-09-07 09:27:24.519069099 -0700
@@ -7677,7 +7677,7 @@ static void ixgbe_io_resume(struct pci_d
 	netif_device_attach(netdev);
 }
 
-static struct pci_error_handlers ixgbe_err_handler = {
+static const struct pci_error_handlers ixgbe_err_handler = {
 	.error_detected = ixgbe_io_error_detected,
 	.slot_reset = ixgbe_io_slot_reset,
 	.resume = ixgbe_io_resume,
--- a/drivers/net/ethernet/neterion/s2io.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/neterion/s2io.c	2012-09-07 09:27:24.519069099 -0700
@@ -484,7 +484,7 @@ static DEFINE_PCI_DEVICE_TABLE(s2io_tbl)
 
 MODULE_DEVICE_TABLE(pci, s2io_tbl);
 
-static struct pci_error_handlers s2io_err_handler = {
+static const struct pci_error_handlers s2io_err_handler = {
 	.error_detected = s2io_io_error_detected,
 	.slot_reset = s2io_io_slot_reset,
 	.resume = s2io_io_resume,
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c	2012-09-07 09:27:24.519069099 -0700
@@ -4799,7 +4799,7 @@ static void __devexit vxge_remove(struct
 			     __LINE__);
 }
 
-static struct pci_error_handlers vxge_err_handler = {
+static const struct pci_error_handlers vxge_err_handler = {
 	.error_detected = vxge_io_error_detected,
 	.slot_reset = vxge_io_slot_reset,
 	.resume = vxge_io_resume,
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c	2012-09-07 09:27:24.519069099 -0700
@@ -2795,7 +2795,7 @@ static const struct dev_pm_ops pch_gbe_p
 };
 #endif
 
-static struct pci_error_handlers pch_gbe_err_handler = {
+static const struct pci_error_handlers pch_gbe_err_handler = {
 	.error_detected = pch_gbe_io_error_detected,
 	.slot_reset = pch_gbe_io_slot_reset,
 	.resume = pch_gbe_io_resume
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c	2012-09-07 09:27:24.523069059 -0700
@@ -3336,7 +3336,7 @@ netxen_free_vlan_ip_list(struct netxen_a
 { }
 #endif
 
-static struct pci_error_handlers netxen_err_handler = {
+static const struct pci_error_handlers netxen_err_handler = {
 	.error_detected = netxen_io_error_detected,
 	.slot_reset = netxen_io_slot_reset,
 	.resume = netxen_io_resume,
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c	2012-09-07 09:27:24.523069059 -0700
@@ -4522,7 +4522,7 @@ static void
 qlcnic_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
 #endif
-static struct pci_error_handlers qlcnic_err_handler = {
+static const struct pci_error_handlers qlcnic_err_handler = {
 	.error_detected = qlcnic_io_error_detected,
 	.slot_reset = qlcnic_io_slot_reset,
 	.resume = qlcnic_io_resume,
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c	2012-09-07 09:27:24.523069059 -0700
@@ -4847,7 +4847,7 @@ static void qlge_io_resume(struct pci_de
 	netif_device_attach(ndev);
 }
 
-static struct pci_error_handlers qlge_err_handler = {
+static const struct pci_error_handlers qlge_err_handler = {
 	.error_detected = qlge_io_error_detected,
 	.slot_reset = qlge_io_slot_reset,
 	.resume = qlge_io_resume,
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c	2012-09-07 09:27:24.523069059 -0700
@@ -3256,7 +3256,7 @@ static void ixgbevf_io_resume(struct pci
 }
 
 /* PCI Error Recovery (ERS) */
-static struct pci_error_handlers ixgbevf_err_handler = {
+static const struct pci_error_handlers ixgbevf_err_handler = {
 	.error_detected = ixgbevf_io_error_detected,
 	.slot_reset = ixgbevf_io_slot_reset,
 	.resume = ixgbevf_io_resume,
--- a/drivers/net/ethernet/mellanox/mlx4/main.c	2012-09-07 09:21:37.154557681 -0700
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c	2012-09-07 09:27:24.523069059 -0700
@@ -2301,7 +2301,7 @@ static pci_ers_result_t mlx4_pci_slot_re
 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
 }
 
-static struct pci_error_handlers mlx4_err_handler = {
+static const struct pci_error_handlers mlx4_err_handler = {
 	.error_detected = mlx4_pci_err_detected,
 	.slot_reset     = mlx4_pci_slot_reset,
 };

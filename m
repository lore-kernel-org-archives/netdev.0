From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [ PATCH net-next]  qlcnic: fix sparse warnings
Date: Sat, 18 Jan 2014 17:21:13 -0800
Message-ID: <20140118172113.16adb69f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:54911 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaASBVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 20:21:16 -0500
Received: by mail-pb0-f43.google.com with SMTP id md12so5555687pbc.16
        for <netdev@vger.kernel.org>; Sat, 18 Jan 2014 17:21:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fengguang Wu <fengguang.wu@intel.com>

Previous patch changed prototypes, but forgot functions.

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Acked-by: Stephen Hemminger <stephen@networkplumber.org>

---
 qlcnic_83xx_hw.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2014-01-18 13:41:07.000000000 -0800
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c	2014-01-18 17:13:08.640658697 -0800
@@ -2066,7 +2066,7 @@ void qlcnic_83xx_change_l2_filter(struct
 	qlcnic_83xx_sre_macaddr_change(adapter, mac, vlan_id, QLCNIC_MAC_ADD);
 }
 
-void qlcnic_83xx_configure_mac(struct qlcnic_adapter *adapter, u8 *mac,
+static void qlcnic_83xx_configure_mac(struct qlcnic_adapter *adapter, u8 *mac,
 			       u8 type, struct qlcnic_cmd_args *cmd)
 {
 	switch (type) {
@@ -2170,7 +2170,7 @@ static void qlcnic_83xx_handle_link_aen(
 	qlcnic_advert_link_change(adapter, link_status);
 }
 
-irqreturn_t qlcnic_83xx_handle_aen(int irq, void *data)
+static irqreturn_t qlcnic_83xx_handle_aen(int irq, void *data)
 {
 	struct qlcnic_adapter *adapter = data;
 	struct qlcnic_mailbox *mbx;
@@ -3517,7 +3517,7 @@ int qlcnic_83xx_flash_test(struct qlcnic
 	return 0;
 }
 
-int qlcnic_83xx_shutdown(struct pci_dev *pdev)
+static int qlcnic_83xx_shutdown(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
@@ -3892,7 +3892,7 @@ int qlcnic_83xx_init_mailbox_work(struct
 	return 0;
 }
 
-pci_ers_result_t qlcnic_83xx_io_error_detected(struct pci_dev *pdev,
+static pci_ers_result_t qlcnic_83xx_io_error_detected(struct pci_dev *pdev,
 					       pci_channel_state_t state)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
@@ -3914,7 +3914,7 @@ pci_ers_result_t qlcnic_83xx_io_error_de
 	return PCI_ERS_RESULT_NEED_RESET;
 }
 
-pci_ers_result_t qlcnic_83xx_io_slot_reset(struct pci_dev *pdev)
+static pci_ers_result_t qlcnic_83xx_io_slot_reset(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
 	int err = 0;
@@ -3937,7 +3937,7 @@ disconnect:
 	return PCI_ERS_RESULT_DISCONNECT;
 }
 
-void qlcnic_83xx_io_resume(struct pci_dev *pdev)
+static void qlcnic_83xx_io_resume(struct pci_dev *pdev)
 {
 	struct qlcnic_adapter *adapter = pci_get_drvdata(pdev);
 

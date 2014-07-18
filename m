From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 15/25] qlcnic: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:27:02 +0200
Message-ID: <1405697232-11785-16-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, Dept-HSGLinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0fdbcc8..2bf7d9d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -108,7 +108,7 @@ static u32 qlcnic_vlan_tx_check(struct qlcnic_adapter *adapter)
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
-static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
+static const struct pci_device_id qlcnic_pci_tbl[] = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE834X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE834X),

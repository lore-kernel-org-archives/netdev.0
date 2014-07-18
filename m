From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 12/25] r8169: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:26:59 +0200
Message-ID: <1405697232-11785-13-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/ethernet/realtek/r8169.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 9887bcb..91652e7 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -291,7 +291,7 @@ enum cfg_version {
 	RTL_CFG_2
 };
 
-static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
+static const struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_0 },

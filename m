From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 9/25] net: neterion: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:26:56 +0200
Message-ID: <1405697232-11785-10-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/ethernet/neterion/s2io.c           |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index be58764..f5e4b82 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -471,7 +471,7 @@ module_param_array(rts_frm_len, uint, NULL, 0);
  * S2IO device table.
  * This table lists all the devices that this driver supports.
  */
-static DEFINE_PCI_DEVICE_TABLE(s2io_tbl) = {
+static const struct pci_device_id s2io_tbl[] = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_WIN,
 	 PCI_ANY_ID, PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_UNI,
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 7a0dead..061dcf2 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -63,7 +63,7 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_DESCRIPTION("Neterion's X3100 Series 10GbE PCIe I/O"
 	"Virtualized Server Adapter");
 
-static DEFINE_PCI_DEVICE_TABLE(vxge_id_table) = {
+static const struct pci_device_id vxge_id_table[] = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_TITAN_WIN, PCI_ANY_ID,
 	PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_TITAN_UNI, PCI_ANY_ID,

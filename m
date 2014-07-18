From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 24/25] starfire: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:27:11 +0200
Message-ID: <1405697232-11785-25-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ion Badulescu <ionut@badula.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/ethernet/adaptec/starfire.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 40dbbf7..ac72882 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -285,7 +285,7 @@ enum chipset {
 	CH_6915 = 0,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(starfire_pci_tbl) = {
+static const struct pci_device_id starfire_pci_tbl[] = {
 	{ PCI_VDEVICE(ADAPTEC, 0x6915), CH_6915 },
 	{ 0, }
 };

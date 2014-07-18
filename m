From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 14/25] adm8211: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:27:01 +0200
Message-ID: <1405697232-11785-15-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/wireless/adm8211.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index f35f93c..17fcaab 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -41,7 +41,7 @@ static unsigned int rx_ring_size __read_mostly = 16;
 module_param(tx_ring_size, uint, 0);
 module_param(rx_ring_size, uint, 0);
 
-static DEFINE_PCI_DEVICE_TABLE(adm8211_pci_id_table) = {
+static const struct pci_device_id adm8211_pci_id_table[] = {
 	/* ADMtek ADM8211 */
 	{ PCI_DEVICE(0x10B7, 0x6000) }, /* 3Com 3CRSHPW796 */
 	{ PCI_DEVICE(0x1200, 0x8201) }, /* ? */

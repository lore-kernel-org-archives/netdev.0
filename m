From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 5/25] net/ethernet/sgi/ioc3-eth: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:26:52 +0200
Message-ID: <1405697232-11785-6-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, linux-mips@linux-mips.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Not tested.

 drivers/net/ethernet/sgi/ioc3-eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 7984ad0..7a254da 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1384,7 +1384,7 @@ static void ioc3_remove_one(struct pci_dev *pdev)
 	 */
 }
 
-static DEFINE_PCI_DEVICE_TABLE(ioc3_pci_tbl) = {
+static const struct pci_device_id ioc3_pci_tbl[] = {
 	{ PCI_VENDOR_ID_SGI, PCI_DEVICE_ID_SGI_IOC3, PCI_ANY_ID, PCI_ANY_ID },
 	{ 0 }
 };

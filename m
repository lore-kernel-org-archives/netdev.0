From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/9] net: cavium: liquidio: constify pci_error_handlers structures
Date: Sat, 14 Nov 2015 11:06:53 +0100
Message-ID: <1447495621-9161-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1447495621-9161-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447495621-9161-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This pci_error_handlers structure is never modified, like all the other
pci_error_handlers structures, so declare it as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
There are no dependencies between these patches.

 drivers/net/ethernet/cavium/liquidio/lio_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index f683d97..b895044 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -560,7 +560,7 @@ static int liquidio_resume(struct pci_dev *pdev)
 #endif
 
 /* For PCI-E Advanced Error Recovery (AER) Interface */
-static struct pci_error_handlers liquidio_err_handler = {
+static const struct pci_error_handlers liquidio_err_handler = {
 	.error_detected = liquidio_pcie_error_detected,
 	.mmio_enabled	= liquidio_pcie_mmio_enabled,
 	.slot_reset	= liquidio_pcie_slot_reset,

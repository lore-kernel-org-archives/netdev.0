From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: tehuti: fix typo: "eneble" -> "enable"
Date: Sun, 21 Aug 2016 15:24:33 +0100
Message-ID: <20160821142433.8323-1-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial typo fix in pr_err message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/tehuti/tehuti.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 7452b5f..7108c68 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1987,7 +1987,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if ((readl(nic->regs + FPGA_VER) & 0xFFF) >= 378) {
 		err = pci_enable_msi(pdev);
 		if (err)
-			pr_err("Can't eneble msi. error is %d\n", err);
+			pr_err("Can't enable msi. error is %d\n", err);
 		else
 			nic->irq_type = IRQ_MSI;
 	} else
-- 
2.9.3

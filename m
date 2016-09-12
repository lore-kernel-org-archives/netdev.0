From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: r6040: add in missing white space in error message text
Date: Mon, 12 Sep 2016 13:08:57 +0100
Message-ID: <20160912120857.31600-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

A couple of dev_err messages span two lines and the literal
string is missing a white space between words. Add the white
space.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/rdc/r6040.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index cb29ee2..5dc655b 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1062,13 +1062,13 @@ static int r6040_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* this should always be supported */
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
-		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
+		dev_err(&pdev->dev, "32-bit PCI DMA addresses "
 				"not supported by the card\n");
 		goto err_out_disable_dev;
 	}
 	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
-		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
+		dev_err(&pdev->dev, "32-bit PCI DMA addresses "
 				"not supported by the card\n");
 		goto err_out_disable_dev;
 	}
-- 
2.9.3

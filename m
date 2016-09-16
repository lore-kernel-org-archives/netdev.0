From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] net: r6040: add in missing white space in error message text
Date: Fri, 16 Sep 2016 10:43:38 +0100
Message-ID: <20160916094338.23698-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

A couple of dev_err messages span two lines and the literal
string is missing a white space between words. Add the white
space and join the two lines into one.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/rdc/r6040.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index cb29ee2..5ef5d72 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1062,14 +1062,12 @@ static int r6040_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* this should always be supported */
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
-		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
-				"not supported by the card\n");
+		dev_err(&pdev->dev, "32-bit PCI DMA addresses not supported by the card\n");
 		goto err_out_disable_dev;
 	}
 	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
-		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
-				"not supported by the card\n");
+		dev_err(&pdev->dev, "32-bit PCI DMA addresses not supported by the card\n");
 		goto err_out_disable_dev;
 	}
 
-- 
2.9.3

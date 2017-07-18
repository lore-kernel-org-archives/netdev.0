From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] net: tulip: remove useless code in tulip_init_one()
Date: Tue, 18 Jul 2017 15:43:33 -0500
Message-ID: <20170718204333.GA12258@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: linux-parisc@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove useless local variable multiport_cnt and the code related.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 drivers/net/ethernet/dec/tulip/tulip_core.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 17e566a..84394b4 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1303,7 +1303,6 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		0x00, 'L', 'i', 'n', 'u', 'x'
 	};
 	static int last_irq;
-	static int multiport_cnt;	/* For four-port boards w/one EEPROM */
 	int i, irq;
 	unsigned short sum;
 	unsigned char *ee_data;
@@ -1557,7 +1556,6 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		} else if (ee_data[0] == 0xff  &&  ee_data[1] == 0xff &&
 				   ee_data[2] == 0) {
 			sa_offset = 2;		/* Grrr, damn Matrox boards. */
-			multiport_cnt = 4;
 		}
 #ifdef CONFIG_MIPS_COBALT
                if ((pdev->bus->number == 0) &&
-- 
2.5.0


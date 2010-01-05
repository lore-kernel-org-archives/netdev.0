From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/atm/nicstar.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 09:28:08 -0700
Message-ID: <201001050928.09040.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755072Ab0AEQkm@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 3da804b..5083840 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -807,9 +807,7 @@ static int __devinit ns_init_card(int i, struct pci_dev *pcidev)
       }
    }
 
-   printk("nicstar%d: MAC address %02X:%02X:%02X:%02X:%02X:%02X\n", i,
-          card->atmdev->esi[0], card->atmdev->esi[1], card->atmdev->esi[2],
-          card->atmdev->esi[3], card->atmdev->esi[4], card->atmdev->esi[5]);
+   printk("nicstar%d: MAC address %pM\n", i, card->atmdev->esi);
 
    card->atmdev->dev_data = card;
    card->atmdev->ci_range.vpi_bits = card->vpibits;

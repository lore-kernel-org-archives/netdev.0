From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/atm/nicstar.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 13:55:36 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F648@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og116.obsmtp.com ([64.18.1.37]:38331 "HELO
	exprod6og116.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752752AbZL3Szg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 13:55:36 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

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

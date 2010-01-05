From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] drivers/atm/idt77252.c: use %pM to show MAC address
Date: Tue, 5 Jan 2010 09:24:23 -0700
Message-ID: <201001050924.23939.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755002Ab0AEQkg@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

Repost due to merge issues.

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index e33ae00..01f36c0 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3557,10 +3557,7 @@ init_card(struct atm_dev *dev)
 	if (tmp) {
 		memcpy(card->atmdev->esi, tmp->dev_addr, 6);
 
-		printk("%s: ESI %02x:%02x:%02x:%02x:%02x:%02x\n",
-		       card->name, card->atmdev->esi[0], card->atmdev->esi[1],
-		       card->atmdev->esi[2], card->atmdev->esi[3],
-		       card->atmdev->esi[4], card->atmdev->esi[5]);
+		printk("%s: ESI %pM\n", card->name, card->atmdev->esi);
 	}
 	/*
 	 * XXX: </hack>

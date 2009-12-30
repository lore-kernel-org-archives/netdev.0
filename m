From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/atm/idt77252.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 14:41:41 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F664@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og115.obsmtp.com ([64.18.1.35]:41755 "HELO
	exprod6og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752948AbZL3Tll convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 14:41:41 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM kernel extension to display the MAC address.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

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

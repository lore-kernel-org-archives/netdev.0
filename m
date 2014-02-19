From: Daeseok Youn <daeseok.youn@gmail.com>
Subject: [PATCH] atm: solos-pci: make solos_bh() as static
Date: Wed, 19 Feb 2014 14:13:54 +0900
Message-ID: <1547067.MtNWZjBp8J@daeseok-laptop.cloud.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 6297aabeff748777b520cc0ee835af0a3ddc79e2 Mon Sep 17 00:00:00 2001
From: Daeseok Youn <daeseok.youn@gmail.com>
Date: Wed, 19 Feb 2014 10:49:12 +0900
Subject: [PATCH] atm: solos-pci: make solos_bh() as static

sparse says:

drivers/atm/solos-pci.c:763:6: warning:
 symbol 'solos_bh' was not declared. Should it be static?

Signed-off-by: Daeseok Youn <daeseok.youn@gmail.com>
---
 drivers/atm/solos-pci.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index e3fb496..943cf0d 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -760,7 +760,7 @@ static irqreturn_t solos_irq(int irq, void *dev_id)
 	return IRQ_RETVAL(handled);
 }
 
-void solos_bh(unsigned long card_arg)
+static void solos_bh(unsigned long card_arg)
 {
 	struct solos_card *card = (void *)card_arg;
 	uint32_t card_flags;
-- 
1.7.9.5

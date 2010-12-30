From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 10/15]drivers:usb:gadget:langwell Typo change diable to disable.
Date: Thu, 30 Dec 2010 15:07:59 -0800
Message-ID: <1293750484-1161-10-git-send-email-justinmattock@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-3-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-4-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-5-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-6-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-7-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-8-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-9-git-send-email-justinmattock@gmail.com>
Cc: linux-m68k@lists.linux-m68k.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, ivtv-devel@ivtvdriver.org,
	linux-media@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:58873 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847Ab0L3XIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 18:08:39 -0500
In-Reply-To: <1293750484-1161-9-git-send-email-justinmattock@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The below patch fixes a typo "diable" to "disable". Please let me know if this 
is correct or not. 

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/usb/gadget/langwell_udc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/gadget/langwell_udc.c b/drivers/usb/gadget/langwell_udc.c
index b8ec954..dad278f 100644
--- a/drivers/usb/gadget/langwell_udc.c
+++ b/drivers/usb/gadget/langwell_udc.c
@@ -3063,7 +3063,7 @@ static void langwell_udc_remove(struct pci_dev *pdev)
 
 	kfree(dev->ep);
 
-	/* diable IRQ handler */
+	/* disable IRQ handler */
 	if (dev->got_irq)
 		free_irq(pdev->irq, dev);
 
@@ -3383,7 +3383,7 @@ static int langwell_udc_suspend(struct pci_dev *pdev, pm_message_t state)
 	/* disable interrupt and set controller to stop state */
 	langwell_udc_stop(dev);
 
-	/* diable IRQ handler */
+	/* disable IRQ handler */
 	if (dev->got_irq)
 		free_irq(pdev->irq, dev);
 	dev->got_irq = 0;
-- 
1.6.5.2.180.gc5b3e


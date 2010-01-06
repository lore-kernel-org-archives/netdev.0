From: Stefan Weil <weil@mail.berlios.de>
Subject: [PATCH] Fix spelling in log messages
Date: Thu,  7 Jan 2010 00:05:37 +0100
Message-ID: <1262819137-16775-1-git-send-email-weil__8300.37192577056$1262819199$gmane$org@mail.berlios.de>
Cc: Stefan Weil <weil@mail.berlios.de>
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Dave Young <hidave.darkstar@gmail.com>,
	Matthew Garrett <mjg@redhat.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-input@vger.kern
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:64150 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932958Ab0AFXGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 18:06:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace platfrom -> platform.

Signed-off-by: Stefan Weil <weil@mail.berlios.de>
---
 drivers/input/serio/i8042.c |    2 +-
 drivers/net/davinci_emac.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/input/serio/i8042.c b/drivers/input/serio/i8042.c
index d84a36e..33f3541 100644
--- a/drivers/input/serio/i8042.c
+++ b/drivers/input/serio/i8042.c
@@ -430,7 +430,7 @@ static bool i8042_filter(unsigned char data, unsigned char str,
 	}
 
 	if (i8042_platform_filter && i8042_platform_filter(data, str, serio)) {
-		dbg("Filtered out by platfrom filter\n");
+		dbg("Filtered out by platform filter\n");
 		return true;
 	}
 
diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 107bc5f..4741ade 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2652,7 +2652,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 
 	pdata = pdev->dev.platform_data;
 	if (!pdata) {
-		printk(KERN_ERR "DaVinci EMAC: No platfrom data\n");
+		printk(KERN_ERR "DaVinci EMAC: No platform data\n");
 		return -ENODEV;
 	}
 
-- 
1.5.6.5


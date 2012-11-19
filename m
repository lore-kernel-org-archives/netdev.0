From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 082/493] ieee802154: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:20:31 -0500
Message-ID: <1353349642-3677-82-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41684 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754055Ab2KSSiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:38:18 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: netdev@vger.kernel.org 
---
 drivers/net/ieee802154/at86rf230.c | 2 +-
 drivers/net/ieee802154/fakehard.c  | 2 +-
 drivers/net/ieee802154/fakelb.c    | 2 +-
 drivers/net/ieee802154/mrf24j40.c  | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index ba753d8..cbb08de 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -947,7 +947,7 @@ static struct spi_driver at86rf230_driver = {
 		.owner	= THIS_MODULE,
 	},
 	.probe      = at86rf230_probe,
-	.remove     = __devexit_p(at86rf230_remove),
+	.remove     = at86rf230_remove,
 	.suspend    = at86rf230_suspend,
 	.resume     = at86rf230_resume,
 };
diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index 7d39add..8c719e0 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -423,7 +423,7 @@ static struct platform_device *ieee802154fake_dev;
 
 static struct platform_driver ieee802154fake_driver = {
 	.probe = ieee802154fake_probe,
-	.remove = __devexit_p(ieee802154fake_remove),
+	.remove = ieee802154fake_remove,
 	.driver = {
 			.name = "ieee802154hardmac",
 			.owner = THIS_MODULE,
diff --git a/drivers/net/ieee802154/fakelb.c b/drivers/net/ieee802154/fakelb.c
index e7456fc..2d2e027 100644
--- a/drivers/net/ieee802154/fakelb.c
+++ b/drivers/net/ieee802154/fakelb.c
@@ -269,7 +269,7 @@ static struct platform_device *ieee802154fake_dev;
 
 static struct platform_driver ieee802154fake_driver = {
 	.probe = fakelb_probe,
-	.remove = __devexit_p(fakelb_remove),
+	.remove = fakelb_remove,
 	.driver = {
 			.name = "ieee802154fakelb",
 			.owner = THIS_MODULE,
diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index ed75216..90b5467 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -746,7 +746,7 @@ static struct spi_driver mrf24j40_driver = {
 	},
 	.id_table = mrf24j40_ids,
 	.probe = mrf24j40_probe,
-	.remove = __devexit_p(mrf24j40_remove),
+	.remove = mrf24j40_remove,
 };
 
 static int __init mrf24j40_init(void)
-- 
1.8.0

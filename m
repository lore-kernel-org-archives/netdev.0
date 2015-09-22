From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] ch9200: Convert to use module_usb_driver
Date: Tue, 22 Sep 2015 09:29:49 +0200
Message-ID: <1442906989-10664-1-git-send-email-tklauser@distanz.ch>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34437 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932484AbbIVH36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 03:29:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converts the ch9200 driver to use the module_usb_driver() macro which
makes the code smaller and a bit simpler.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/usb/ch9200.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/usb/ch9200.c b/drivers/net/usb/ch9200.c
index cabb670..5e151e6 100644
--- a/drivers/net/usb/ch9200.c
+++ b/drivers/net/usb/ch9200.c
@@ -426,18 +426,7 @@ static struct usb_driver ch9200_driver = {
 	.resume = usbnet_resume,
 };
 
-static int __init ch9200_init(void)
-{
-	return usb_register(&ch9200_driver);
-}
-
-static void __exit ch9200_exit(void)
-{
-	usb_deregister(&ch9200_driver);
-}
-
-module_init(ch9200_init);
-module_exit(ch9200_exit);
+module_usb_driver(ch9200_driver);
 
 MODULE_DESCRIPTION("QinHeng CH9200 USB Network device");
 MODULE_LICENSE("GPL");
-- 
2.5.0

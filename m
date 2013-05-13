From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/2] net/usb: r8152: Use module_usb_driver()
Date: Mon, 13 May 2013 10:25:23 +0530
Message-ID: <1368420923-32222-2-git-send-email-sachin.kamat@linaro.org>
References: <1368420923-32222-1-git-send-email-sachin.kamat@linaro.org>
Cc: nic_swsd@realtek.com, hayeswang@realtek.com, davem@davemloft.net,
	sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55941 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660Ab3EMFIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 01:08:45 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq13so579696pbb.19
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 22:08:44 -0700 (PDT)
In-Reply-To: <1368420923-32222-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_usb_driver() eliminates boilerplate and simplifies the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/usb/r8152.c |   13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 8e53e41..d02bac8 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1748,18 +1748,7 @@ static struct usb_driver rtl8152_driver = {
 	.resume =	rtl8152_resume
 };
 
-static int __init usb_rtl8152_init(void)
-{
-	return usb_register(&rtl8152_driver);
-}
-
-static void __exit usb_rtl8152_exit(void)
-{
-	usb_deregister(&rtl8152_driver);
-}
-
-module_init(usb_rtl8152_init);
-module_exit(usb_rtl8152_exit);
+module_usb_driver(rtl8152_driver);
 
 MODULE_AUTHOR(DRIVER_AUTHOR);
 MODULE_DESCRIPTION(DRIVER_DESC);
-- 
1.7.9.5

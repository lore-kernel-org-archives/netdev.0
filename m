From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH Resend 2/2] net/usb: r8152: Use module_usb_driver()
Date: Fri, 17 May 2013 09:18:08 +0530
Message-ID: <1368762488-22017-2-git-send-email-sachin.kamat@linaro.org>
References: <1368762488-22017-1-git-send-email-sachin.kamat@linaro.org>
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	hayeswang@realtek.com, sachin.kamat@linaro.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:50618 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696Ab3EQECg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 00:02:36 -0400
Received: by mail-pd0-f170.google.com with SMTP id 15so187200pdi.29
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 21:02:36 -0700 (PDT)
In-Reply-To: <1368762488-22017-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_usb_driver() eliminates boilerplate and simplifies the code.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
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

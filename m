From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 31/31] net: mdio-mux-gpio: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:09:26 +0900
Message-ID: <004f01cea53f$19455560$4bd00020$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:62466 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab3H3FJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:09:26 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB00D50VNBR5Q0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:09:26 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/phy/mdio-mux-gpio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
index e91d7d7..d2dd9e4 100644
--- a/drivers/net/phy/mdio-mux-gpio.c
+++ b/drivers/net/phy/mdio-mux-gpio.c
@@ -106,7 +106,7 @@ err:
 
 static int mdio_mux_gpio_remove(struct platform_device *pdev)
 {
-	struct mdio_mux_gpio_state *s = pdev->dev.platform_data;
+	struct mdio_mux_gpio_state *s = dev_get_platdata(&pdev->dev);
 	mdio_mux_uninit(s->mux_handle);
 	return 0;
 }
-- 
1.7.10.4

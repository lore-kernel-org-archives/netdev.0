From: Wan ZongShun <mcuos.com@gmail.com>
Subject: [PATCH] net: Rename MAC platform driver for w90p910 platform
Date: Mon, 17 Aug 2009 12:00:40 +0800
Message-ID: <4A88D5E8.9070708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:62452 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbZHQEAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 00:00:44 -0400
Received: by rv-out-0506.google.com with SMTP id f6so713244rvb.1
        for <netdev@vger.kernel.org>; Sun, 16 Aug 2009 21:00:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David,

Due to I modified the corresponding platform device name, 
so I make the patch to rename MAC platform driver
for w90p910 platform.

Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>

---
 drivers/net/arm/w90p910_ether.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 890716f..3a0948f 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -1098,7 +1098,7 @@ static struct platform_driver w90p910_ether_driver = {
 	.probe		= w90p910_ether_probe,
 	.remove		= __devexit_p(w90p910_ether_remove),
 	.driver		= {
-		.name	= "w90p910-emc",
+		.name	= "nuc900-emc",
 		.owner	= THIS_MODULE,
 	},
 };
@@ -1119,5 +1119,5 @@ module_exit(w90p910_ether_exit);
 MODULE_AUTHOR("Wan ZongShun <mcuos.com@gmail.com>");
 MODULE_DESCRIPTION("w90p910 MAC driver!");
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("platform:w90p910-emc");
+MODULE_ALIAS("platform:nuc900-emc");
 
-- 
1.5.6.3

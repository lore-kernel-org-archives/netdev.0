From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: sun4i-emac: fix a typo in emac_probe()
Date: Mon, 3 Jun 2013 21:36:52 +0800
Message-ID: <CAPgLHd-fXnt9H_CxDD1Ww=C-6nn3COVkYirKY6ucOJVR2Pkwkw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: grant.likely@linaro.org, rob.herring@calxeda.com,
	maxime.ripard@free-electrons.com, davem@davemloft.net, sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:55652 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757521Ab3FCNgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 09:36:54 -0400
Received: by mail-bk0-f49.google.com with SMTP id 6so1916596bkj.36
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 06:36:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Just fixed a typo in emac_probe().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index b411344..26083cd 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -821,7 +821,7 @@ static int emac_probe(struct platform_device *pdev)
 	db->membase = of_iomap(np, 0);
 	if (!db->membase) {
 		dev_err(&pdev->dev, "failed to remap registers\n");
-		return -ENOMEM;
+		ret = -ENOMEM;
 		goto out;
 	}
 

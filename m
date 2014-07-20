From: weiyj_lk@163.com
Subject: [PATCH -next] net: mvpp2: Remove redundant dev_err call in mvpp2_port_probe()
Date: Sun, 20 Jul 2014 21:57:17 +0800
Message-ID: <1405864637-13737-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>, netdev@vger.kernel.org
To: Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:36020 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbaGTN5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jul 2014 09:57:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

There is a error message within devm_ioremap_resource
already, so remove the dev_err call to avoid redundant
error message.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/marvell/mvpp2.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 9463ede..d6e997d 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6062,7 +6062,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	port->base = devm_ioremap_resource(&pdev->dev, res);
 	if (IS_ERR(port->base)) {
 		err = PTR_ERR(port->base);
-		dev_err(&pdev->dev, "cannot obtain port base address\n");
 		goto err_free_irq;
 	}
 

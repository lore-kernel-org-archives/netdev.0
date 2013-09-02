From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] net: netx-eth: remove unnecessary casting when using
 dev_get_platdata()
Date: Mon, 02 Sep 2013 09:37:23 +0900
Message-ID: <004b01cea774$975b48b0$c611da10$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:25273 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816Ab3IBAh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Sep 2013 20:37:26 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSH008KT327ANB0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Mon, 02 Sep 2013 09:37:24 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Casting from 'void *' is unnecessary when using dev_get_platdata().

Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/netx-eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 235fd51..e6f0a43 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -390,7 +390,7 @@ static int netx_eth_drv_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(ndev);
 
-	pdata = (struct netxeth_platform_data *)dev_get_platdata(&pdev->dev);
+	pdata = dev_get_platdata(&pdev->dev);
 	priv->xc = request_xc(pdata->xcno, &pdev->dev);
 	if (!priv->xc) {
 		dev_err(&pdev->dev, "unable to request xc engine\n");
-- 
1.7.10.4

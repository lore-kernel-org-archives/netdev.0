From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2] net: netx-eth: remove unnecessary casting
Date: Tue, 03 Sep 2013 08:54:04 +0900
Message-ID: <001101cea837$b49bf370$1dd3da50$%han@samsung.com>
References: <004b01cea774$975b48b0$c611da10$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Sergei Shtylyov' <sergei.shtylyov@cogentembedded.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:53664 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756204Ab3IBXyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 19:54:08 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSI00CECVQ11820@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 03 Sep 2013 08:54:06 +0900 (KST)
In-reply-to: <004b01cea774$975b48b0$c611da10$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Casting from 'void *' is unnecessary, because casting from 'void *'
to any pointer type is automatic.

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

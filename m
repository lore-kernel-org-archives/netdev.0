From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 18/31] net: smc91x: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:01:35 +0900
Message-ID: <004201cea53e$004859a0$00d90ce0$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Nicolas Pitre' <nico@fluxnic.net>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:9871 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753511Ab3H3FBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:01:35 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB002CWV9ZOIP0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:01:34 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/smsc/smc91x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index cde13be..73be7f3 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2202,7 +2202,7 @@ static void smc_release_datacs(struct platform_device *pdev, struct net_device *
  */
 static int smc_drv_probe(struct platform_device *pdev)
 {
-	struct smc91x_platdata *pd = pdev->dev.platform_data;
+	struct smc91x_platdata *pd = dev_get_platdata(&pdev->dev);
 	struct smc_local *lp;
 	struct net_device *ndev;
 	struct resource *res, *ires;
-- 
1.7.10.4

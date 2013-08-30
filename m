From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 20/31] net: smsc911x: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:02:57 +0900
Message-ID: <004401cea53e$315b3760$9411a620$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	'Steve Glendinning' <steve.glendinning@shawell.net>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:10233 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755034Ab3H3FC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:02:58 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB002GNVCSOIP0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:02:57 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/smsc/smsc911x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index a141921..5fdbc26 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2374,7 +2374,7 @@ static int smsc911x_drv_probe(struct platform_device *pdev)
 	struct device_node *np = pdev->dev.of_node;
 	struct net_device *dev;
 	struct smsc911x_data *pdata;
-	struct smsc911x_platform_config *config = pdev->dev.platform_data;
+	struct smsc911x_platform_config *config = dev_get_platdata(&pdev->dev);
 	struct resource *res, *irq_res;
 	unsigned int intcfg = 0;
 	int res_size, irq_flags;
-- 
1.7.10.4

From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 17/31] net: seeq: use dev_get_platdata()
Date: Fri, 30 Aug 2013 14:00:45 +0900
Message-ID: <004101cea53d$e2729030$a757b090$%han@samsung.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:9638 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675Ab3H3FAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 01:00:45 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSB006M6V87TWN0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 30 Aug 2013 14:00:45 +0900 (KST)
In-reply-to: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper function for retrieving the platform data instead of
accessing dev->platform_data directly. This is a cosmetic change
to make the code simpler and enhance the readability.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/seeq/sgiseeq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/seeq/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
index 856e523..c765718 100644
--- a/drivers/net/ethernet/seeq/sgiseeq.c
+++ b/drivers/net/ethernet/seeq/sgiseeq.c
@@ -721,7 +721,7 @@ static const struct net_device_ops sgiseeq_netdev_ops = {
 
 static int sgiseeq_probe(struct platform_device *pdev)
 {
-	struct sgiseeq_platform_data *pd = pdev->dev.platform_data;
+	struct sgiseeq_platform_data *pd = dev_get_platdata(&pdev->dev);
 	struct hpc3_regs *hpcregs = pd->hpc;
 	struct sgiseeq_init_block *sr;
 	unsigned int irq = pd->irq;
-- 
1.7.10.4

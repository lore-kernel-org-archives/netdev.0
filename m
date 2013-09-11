From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 50/52] net: spider_net: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:10:15 +0900
Message-ID: <007d01ceaec6$58e3e110$0aaba330$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Ishizaki Kou' <kou.ishizaki@toshiba.co.jp>,
	'Jens Osterkamp' <jens@de.ibm.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:51266 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab3IKIKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:10:17 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY007AXBYX56F0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:10:16 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/toshiba/spider_net.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 5734480..3f4a32e 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -2478,7 +2478,6 @@ out_release_regions:
 	pci_release_regions(pdev);
 out_disable_dev:
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	return NULL;
 }
 
-- 
1.7.10.4

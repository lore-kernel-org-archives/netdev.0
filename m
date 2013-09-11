From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 04/52] net: pcnet32: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:25:09 +0900
Message-ID: <004e01ceaec0$0b8ee0f0$22aca2d0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Don Fry' <pcnet32@frontier.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:50744 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229Ab3IKHZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:25:10 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY008G89XBXAN0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:25:09 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/amd/pcnet32.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 2d8e288..40b92e3 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -2818,7 +2818,6 @@ static void pcnet32_remove_one(struct pci_dev *pdev)
 				    lp->init_block, lp->init_dma_addr);
 		free_netdev(dev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4

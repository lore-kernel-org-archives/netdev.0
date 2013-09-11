From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 46/52] net: sungem: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:07:35 +0900
Message-ID: <007901ceaec5$f95942d0$ec0bc870$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:42672 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab3IKIHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:07:38 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00MI4BWOAPP0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:07:36 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/sungem.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index e62df2b..e115bb1 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2806,8 +2806,6 @@ static void gem_remove_one(struct pci_dev *pdev)
 		iounmap(gp->regs);
 		pci_release_regions(pdev);
 		free_netdev(dev);
-
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4

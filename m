From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 6/7] net: tc35815: remove unnecessary pci_set_drvdata()
Date: Wed, 23 Oct 2013 16:09:32 +0900
Message-ID: <000701cecfbe$d2da97c0$788fc740$%han@samsung.com>
References: <000001cecfbe$44ce9c10$ce6bd430$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:15688 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab3JWHJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 03:09:33 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV4006XY17XFVS0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 23 Oct 2013 16:09:33 +0900 (KST)
In-reply-to: <000001cecfbe$44ce9c10$ce6bd430$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/toshiba/tc35815.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index a971b9c..1322546 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -887,7 +887,6 @@ static void tc35815_remove_one(struct pci_dev *pdev)
 	mdiobus_free(lp->mii_bus);
 	unregister_netdev(dev);
 	free_netdev(dev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static int
-- 
1.7.10.4

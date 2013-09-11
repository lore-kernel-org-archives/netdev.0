From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 51/52] net: tc35815: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:10:59 +0900
Message-ID: <007e01ceaec6$72b8e2c0$582aa840$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:51520 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab3IKILA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:11:00 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00BK2C0WDHT0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:10:59 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
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

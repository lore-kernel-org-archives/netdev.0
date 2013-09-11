From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 52/52] net: via-rhine: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:11:38 +0900
Message-ID: <007f01ceaec6$8a65fb60$9f31f220$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Roger Luethi' <rl@hellgate.ch>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:43626 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab3IKILk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:11:40 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY001QCC2UP0N0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:11:39 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/via/via-rhine.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index c8f088a..7711374 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2287,7 +2287,6 @@ static void rhine_remove_one(struct pci_dev *pdev)
 
 	free_netdev(dev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static void rhine_shutdown (struct pci_dev *pdev)
-- 
1.7.10.4

From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 41/52] net: epic100: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:02:58 +0900
Message-ID: <007301ceaec5$540c0fb0$fc242f10$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:33485 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265Ab3IKIDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:03:04 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00A4ZBOTJCW0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:02:58 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/smsc/epic100.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 03b256a..8c5c24a 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -1535,7 +1535,6 @@ static void epic_remove_one(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 	free_netdev(dev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	/* pci_power_off(pdev, -1); */
 }
 
-- 
1.7.10.4

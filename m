From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 44/52] net: sunhme: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:06:33 +0900
Message-ID: <007701ceaec5$d42ea4a0$7c8bede0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 'Jingoo Han' <jg1.han@samsung.com>,
	"'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:34279 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974Ab3IKIGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:06:34 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00ABJBUPJCW0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:06:33 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/sun/sunhme.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index e37b587..201cf63 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -3170,8 +3170,6 @@ static void happy_meal_pci_remove(struct pci_dev *pdev)
 	pci_release_regions(hp->happy_dev);
 
 	free_netdev(net_dev);
-
-	pci_set_drvdata(pdev, NULL);
 }
 
 static DEFINE_PCI_DEVICE_TABLE(happymeal_pci_ids) = {
-- 
1.7.10.4

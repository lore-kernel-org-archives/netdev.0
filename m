From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 48/52] net: tehuti: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:08:50 +0900
Message-ID: <007b01ceaec6$264cad40$72e607c0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Andy Gospodarek' <andy@greyhouse.net>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:42945 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab3IKIIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:08:52 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00214BYIKUM0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:08:51 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/tehuti/tehuti.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 571452e..dd0dd627 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -2447,7 +2447,6 @@ static void bdx_remove(struct pci_dev *pdev)
 	iounmap(nic->regs);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	vfree(nic);
 
 	RET();
-- 
1.7.10.4

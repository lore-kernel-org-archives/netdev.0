From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 18/52] net: dl2k: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:38:28 +0900
Message-ID: <005c01ceaec1$e857ea80$b907bf80$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:28372 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789Ab3IKHib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:38:31 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00AMXAJXWVU0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:38:29 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/dlink/dl2k.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index afa8e3a..4fb756d 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -1746,7 +1746,6 @@ rio_remove1 (struct pci_dev *pdev)
 		pci_release_regions (pdev);
 		pci_disable_device (pdev);
 	}
-	pci_set_drvdata (pdev, NULL);
 }
 
 static struct pci_driver rio_driver = {
-- 
1.7.10.4

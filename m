From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 11/15] net: epic100: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:19:26 +0900
Message-ID: <001101cecedd$e5219280$af64b780$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:54212 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab3JVET2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:19:28 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100CSPYNNFI50@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:19:27 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
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

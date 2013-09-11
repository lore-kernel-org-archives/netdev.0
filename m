From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 06/52] net: alx: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:27:43 +0900
Message-ID: <005001ceaec0$67e24900$37a6db00$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Jay Cliburn' <jcliburn@gmail.com>,
	'Chris Snook' <chris.snook@gmail.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:41488 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338Ab3IKH1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:27:46 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY0002DA1YUPG0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:27:44 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/atheros/alx/main.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 027398e..73fcd1e 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1372,7 +1372,6 @@ static void alx_remove(struct pci_dev *pdev)
 
 	pci_disable_pcie_error_reporting(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 
 	free_netdev(alx->dev);
 }
-- 
1.7.10.4

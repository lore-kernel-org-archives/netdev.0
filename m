From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 06/15] net: alx: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:20:24 +0900
Message-ID: <00b501cecb97$d7128b20$8537a160$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Jay Cliburn' <jcliburn@gmail.com>,
	'Chris Snook' <chris.snook@gmail.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:57896 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755723Ab3JRAUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:20:30 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00GWB8X8ZPE0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:20:25 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
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
index fc95b23..5aa5e81 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1367,7 +1367,6 @@ static void alx_remove(struct pci_dev *pdev)
 
 	pci_disable_pcie_error_reporting(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 
 	free_netdev(alx->dev);
 }
-- 
1.7.10.4

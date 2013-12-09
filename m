From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 5/5] wan: wanxl: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:32:10 +0900
Message-ID: <000e01cef48f$3e91db50$bbb591f0$%han@samsung.com>
References: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Krzysztof Halasa' <khc@pm.waw.pl>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:59142 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760309Ab3LIDcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:32:11 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00J2ESHNO890@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:32:11 +0900 (KST)
In-reply-to: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wan/wanxl.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 4c0a697..f76aa90 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -542,7 +542,6 @@ static void wanxl_pci_remove_one(struct pci_dev *pdev)
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	kfree(card);
 }
 
-- 
1.7.10.4

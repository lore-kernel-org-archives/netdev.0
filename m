From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 5/5] wan: wanxl: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:59:15 +0900
Message-ID: <000f01cee981$f1a8fd40$d4faf7c0$%han@samsung.com>
References: <000b01cee981$9254d850$b6fe88f0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Krzysztof Halasa' <khc@pm.waw.pl>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:59196 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352Ab3KYB7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:59:16 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS00IVLQUR7PC0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:59:15 +0900 (KST)
In-reply-to: <000b01cee981$9254d850$b6fe88f0$%han@samsung.com>
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

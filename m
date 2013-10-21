From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 03/15] net: dl2k: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:11:14 +0900
Message-ID: <003b01cece02$d1895d60$749c1820$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:51535 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242Ab3JUCLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:11:16 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00LMDY13KKE0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:11:15 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
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

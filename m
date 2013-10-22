From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 08/15] net: 8139too: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:17:58 +0900
Message-ID: <000e01cecedd$b0d9c880$128d5980$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:41881 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab3JVESA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:18:00 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100B5LYLZXCK0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:18:00 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/realtek/8139too.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 3ccedeb..50a9210 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -727,7 +727,6 @@ static void __rtl8139_cleanup_dev (struct net_device *dev)
 	pci_release_regions (pdev);
 
 	free_netdev(dev);
-	pci_set_drvdata (pdev, NULL);
 }
 
 
-- 
1.7.10.4

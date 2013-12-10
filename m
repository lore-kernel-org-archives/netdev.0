From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 2/7] net: fddi: remove unnecessary pci_set_drvdata()
Date: Tue, 10 Dec 2013 12:49:34 +0900
Message-ID: <000c01cef55a$d6f56030$84e02090$%han@samsung.com>
References: <000601cef55a$b605fab0$2211f010$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:30936 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab3LJDtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 22:49:36 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXK007XQNYMB990@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 10 Dec 2013 12:49:34 +0900 (KST)
In-reply-to: <000601cef55a$b605fab0$2211f010$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/fddi/skfp/skfddi.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/fddi/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
index 713d303..d5f5812 100644
--- a/drivers/net/fddi/skfp/skfddi.c
+++ b/drivers/net/fddi/skfp/skfddi.c
@@ -351,7 +351,6 @@ static void skfp_remove_one(struct pci_dev *pdev)
 	free_netdev(p);
 
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 /*
-- 
1.7.10.4

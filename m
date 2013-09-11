From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 27/52] net: myri10ge: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 16:50:20 +0900
Message-ID: <006501ceaec3$905f3f20$b11dbd60$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Hyong-Youb Kim' <hykim@myri.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:38641 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab3IKHu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 03:50:27 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY0020YB3LKUL0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 16:50:20 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 149355b..234b330 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -4208,7 +4208,6 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	set_fw_name(mgp, NULL, false);
 	free_netdev(netdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 #define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E 	0x0008
-- 
1.7.10.4

From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 12/15] net: myri10ge: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:15:08 +0900
Message-ID: <004401cece03$5d153de0$173fb9a0$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Hyong-Youb Kim' <hykim@myri.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:60872 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752404Ab3JUCPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:15:09 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00K7SY929V60@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:15:08 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
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
index 1975550..68026f7 100644
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

From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 04/15] net: pcnet32: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:19:23 +0900
Message-ID: <00b301cecb97$b281bbf0$178533d0$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Don Fry' <pcnet32@frontier.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:12519 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755644Ab3JRAUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:20:24 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00DA88WB5HB0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:19:23 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
Acked-by: Don Fry <pcnet32@frontier.com>
---
 drivers/net/ethernet/amd/pcnet32.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index bd4e640..38492e0 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -2818,7 +2818,6 @@ static void pcnet32_remove_one(struct pci_dev *pdev)
 				    lp->init_block, lp->init_dma_addr);
 		free_netdev(dev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4

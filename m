From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 01/15] net: typhoon: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:17:58 +0900
Message-ID: <00b001cecb97$80051500$800f3f00$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'David Dillow' <dave@thedillows.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:57575 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab3JRASF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:18:05 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00GSS8SNZPE0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:17:59 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
Acked-by: David Dillow <dave@thedillows.org>
---
 drivers/net/ethernet/3com/typhoon.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 144942f6..465cc71 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -2525,7 +2525,6 @@ typhoon_remove_one(struct pci_dev *pdev)
 	pci_release_regions(pdev);
 	pci_clear_mwi(pdev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 }
 
-- 
1.7.10.4

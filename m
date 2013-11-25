From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/5] net: bna: remove unnecessary pci_set_drvdata()
Date: Mon, 25 Nov 2013 10:44:56 +0900
Message-ID: <000301cee97f$f45ee060$dd1ca120$%han@samsung.com>
References: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Rasesh Mody' <rmody@brocade.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:55582 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303Ab3KYBpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 20:45:02 -0500
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MWS00I4VQ71AGB0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 25 Nov 2013 10:45:01 +0900 (KST)
In-reply-to: <000101cee97f$b2271ff0$16755fd0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 248bc37..3d151bd 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3262,7 +3262,6 @@ bnad_uninit(struct bnad *bnad)
 
 	if (bnad->bar0)
 		iounmap(bnad->bar0);
-	pci_set_drvdata(bnad->pcidev, NULL);
 }
 
 /*
-- 
1.7.10.4

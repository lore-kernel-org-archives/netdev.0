From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 3/5] net: bna: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:26:44 +0900
Message-ID: <000501cef48e$7c6cedd0$7546c970$%han@samsung.com>
References: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Rasesh Mody' <rmody@brocade.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:58358 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760426Ab3LID0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:26:51 -0500
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00JR7S8LBV90@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:26:45 +0900 (KST)
In-reply-to: <000001cef48e$1ee3c4e0$5cab4ea0$%han@samsung.com>
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

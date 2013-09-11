From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 42/52] net: smsc9420: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:03:48 +0900
Message-ID: <007401ceaec5$72271f80$56755e80$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Steve Glendinning' <steve.glendinning@shawell.net>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:41914 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514Ab3IKID4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:03:56 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY00MBHBQCAPP0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:03:49 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/smsc/smsc9420.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index ffa5c4a..895634e 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1708,8 +1708,6 @@ static void smsc9420_remove(struct pci_dev *pdev)
 	if (!dev)
 		return;
 
-	pci_set_drvdata(pdev, NULL);
-
 	pd = netdev_priv(dev);
 	unregister_netdev(dev);
 
-- 
1.7.10.4

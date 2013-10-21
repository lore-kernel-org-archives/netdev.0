From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 06/15] net: icplus: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:12:38 +0900
Message-ID: <003e01cece03$03bf5e60$0b3e1b20$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>,
	'Sorbica Shieh' <sorbica@icplus.com.tw>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:19567 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155Ab3JUCMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:12:39 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00EDGY4DE9G0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:12:38 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/icplus/ipg.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index bdf5023..25045ae 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -2183,7 +2183,6 @@ static void ipg_remove(struct pci_dev *pdev)
 
 	free_netdev(dev);
 	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static const struct net_device_ops ipg_netdev_ops = {
-- 
1.7.10.4

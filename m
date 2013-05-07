From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 15/36] net: ethernet: freescale: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:34:04 +0900
Message-ID: <001f01ce4adc$1ae29300$50a7b900$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Jim Baxter' <jim_baxter@mentor.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:43720 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758141Ab3EGEeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:34:05 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00DWPVBU0230@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:34:04 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index e25bf83..850f0ba 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2000,8 +2000,6 @@ fec_drv_remove(struct platform_device *pdev)
 	}
 	free_netdev(ndev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	return 0;
 }
 
-- 
1.7.2.5

From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 34/36] net: irda: bfin_sir: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 14:04:09 +0900
Message-ID: <003301ce4ae0$4f1d40d0$ed57c270$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Samuel Ortiz' <samuel@sortiz.org>,
	Sonic Zhang <sonic.zhang@analog.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:41738 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757685Ab3EGFEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:04:11 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00H9AWQW98O0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 14:04:10 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/irda/bfin_sir.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index a06fca6..4258be8 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -792,7 +792,6 @@ static int bfin_sir_remove(struct platform_device *pdev)
 	kfree(self->rx_buff.head);
 	free_netdev(dev);
 	kfree(sir_port);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
-- 
1.7.2.5

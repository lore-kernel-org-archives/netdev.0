From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH] USB2NET: SR9800: use %zu for dma_addr_t
Date: Thu, 13 Feb 2014 15:31:27 +0900
Message-ID: <000101cf2885$395755a0$ac0600e0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Liu Junliang' <liujunliang_ljl@163.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:11940 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbaBMGb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 01:31:29 -0500
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N0X009W78SG9220@mailout3.samsung.com> for
 netdev@vger.kernel.org; Thu, 13 Feb 2014 15:31:28 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use %zu for size_t in order to avoid the following build
warning in printks.

drivers/net/usb/sr9800.c: In function 'sr9800_bind'
drivers/net/usb/sr9800.c:826:2: warning: format '%ld' expects argument of type 'long int' but argument 5 has type 'size_t'
[-Wformat]

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/usb/sr9800.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index 4175eb9..8017108 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -823,7 +823,7 @@ static int sr9800_bind(struct usbnet *dev, struct usb_interface *intf)
 		dev->rx_urb_size =
 			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_2K].size;
 	}
-	netdev_dbg(dev->net, "%s : setting rx_urb_size with : %ld\n", __func__,
+	netdev_dbg(dev->net, "%s : setting rx_urb_size with : %zu\n", __func__,
 		   dev->rx_urb_size);
 	return 0;
 
-- 
1.7.10.4

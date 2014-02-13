From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2] USB2NET: SR9800: use %zu for size_t
Date: Thu, 13 Feb 2014 16:09:58 +0900
Message-ID: <000101cf288a$9afc0800$d0f41800$%han@samsung.com>
References: <000101cf2885$395755a0$ac0600e0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Liu Junliang' <liujunliang_ljl@163.com>,
	'Joe Perches' <joe@perches.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'David Miller' <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:30690 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751174AbaBMHKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 02:10:00 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N0X00KEWAKNSE00@mailout4.samsung.com> for
 netdev@vger.kernel.org; Thu, 13 Feb 2014 16:09:59 +0900 (KST)
In-reply-to: <000101cf2885$395755a0$ac0600e0$%han@samsung.com>
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
Changes since V1:
- Fix the subject of the commit.

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

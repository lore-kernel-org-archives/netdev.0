From: liujunliang_ljl@163.com
Subject: [PATCH] Fix Default to 'y' for SR9800 Device Driver, setting to 'n'
Date: Thu, 13 Feb 2014 12:22:19 +0800
Message-ID: <1392265339-14841-1-git-send-email-liujunliang_ljl@163.com>
Cc: davem@davemloft.net, horms@verge.net.au, joe@perches.com,
	romieu@fr.zoreil.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, sunhecheng@vip.126.com,
	Liu Junliang <liujunliang_ljl@163.com>
To: thierry.reding@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:45888 "EHLO m12-12.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751320AbaBMEXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 23:23:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liu Junliang <liujunliang_ljl@163.com>


Signed-off-by: Liu Junliang <liujunliang_ljl@163.com>
---
 drivers/net/usb/Kconfig |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 2551bf6..82df7c3 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -295,7 +295,6 @@ config USB_NET_SR9800
 	tristate "CoreChip-sz SR9800 based USB 2.0 10/100 ethernet devices"
 	depends on USB_USBNET
 	select CRC32
-	default y
 	---help---
 	  Say Y if you want to use one of the following 100Mbps USB Ethernet
 	  device based on the CoreChip-sz SR9800 chip.
-- 
1.7.9.5

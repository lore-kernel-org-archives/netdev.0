From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] net: remove spurious zd1201 rule.
Date: Mon, 4 Aug 2014 23:47:44 +0200
Message-ID: <20140804214744.GA1862@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Pavel Machek <pavel@ucw.cz>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39944 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbaHDVr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 17:47:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Leftover from 5c601d0c942f5aaf7f3cff7e08f61047d70a964e ("wireless: move
zd1201 where it belongs").

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/Makefile | 1 -
 1 file changed, 1 deletion(-)

It should be able to wait for 8 more years if it's a bit
late for net-next.

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3fef8a8..fa49d45 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -67,7 +67,6 @@ obj-$(CONFIG_USB_PEGASUS)       += usb/
 obj-$(CONFIG_USB_RTL8150)       += usb/
 obj-$(CONFIG_USB_HSO)		+= usb/
 obj-$(CONFIG_USB_USBNET)        += usb/
-obj-$(CONFIG_USB_ZD1201)        += usb/
 obj-$(CONFIG_USB_IPHETH)        += usb/
 obj-$(CONFIG_USB_CDC_PHONET)   += usb/
 
-- 
1.9.3

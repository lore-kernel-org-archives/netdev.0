From: Mattia Dongili <malattia@linux.it>
Subject: [asix] add Buffalo LUA-U2-GT 10/100/1000
Date: Sun, 6 Apr 2008 23:05:16 +0900
Message-ID: <20080406140516.GA18335@inferi.kami.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Hollis <dhollis@davehollis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-220-247-10-204.b-man.svips.gol.ne.jp ([220.247.10.204]:34516
	"EHLO tadamune.kami.home" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751506AbYDFOPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Apr 2008 10:15:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The USB net adapter Buffalo LUA-U2-GT (0411:006e) carries a
AX88178 chip. Tested on the above HW.

Signed-off-by: Mattia Dongili <malattia@linux.it>
---
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 6f245cf..dc6f097 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1381,6 +1381,10 @@ static const struct usb_device_id	products [] = {
 	USB_DEVICE (0x0411, 0x003d),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
+	// Buffalo LUA-U2-GT 10/100/1000
+	USB_DEVICE (0x0411, 0x006e),
+	.driver_info =  (unsigned long) &ax88178_info,
+}, {
 	// Sitecom LN-029 "USB 2.0 10/100 Ethernet adapter"
 	USB_DEVICE (0x6189, 0x182d),
 	.driver_info =  (unsigned long) &ax8817x_info,
-- 
mattia
:wq!

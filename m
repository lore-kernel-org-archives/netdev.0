From: akpm@linux-foundation.org
Subject: [patch 5/5] obsolete config in kernel source: HSO_AUTOPM
Date: Thu, 11 Mar 2010 14:07:54 -0800
Message-ID: <201003112207.o2BM7sbR013498@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	siccegge@stud.informatik.uni-erlangen.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51353 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758308Ab0CKWIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 17:08:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>

CONFIG_HSO_AUTOPM is set by KConfig / set in the Kernel source, makefiles
and won't be ever set this way, therefor simply removing the protected
code.

Signed-off-by: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/usb/hso.c |    3 ---
 1 file changed, 3 deletions(-)

diff -puN drivers/net/usb/hso.c~obsolete-config-in-kernel-source-hso_autopm drivers/net/usb/hso.c
--- a/drivers/net/usb/hso.c~obsolete-config-in-kernel-source-hso_autopm
+++ a/drivers/net/usb/hso.c
@@ -1155,9 +1155,6 @@ static void _hso_serial_set_termios(stru
 static void hso_resubmit_rx_bulk_urb(struct hso_serial *serial, struct urb *urb)
 {
 	int result;
-#ifdef CONFIG_HSO_AUTOPM
-	usb_mark_last_busy(urb->dev);
-#endif
 	/* We are done with this URB, resubmit it. Prep the USB to wait for
 	 * another frame */
 	usb_fill_bulk_urb(urb, serial->parent->usb,
_

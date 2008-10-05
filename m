From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.27-rc8] drivers/net/usb/Makefile - shrink logspam
Date: Sun, 5 Oct 2008 01:11:12 -0700
Message-ID: <200810050111.12597.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp124.sbc.mail.sp1.yahoo.com ([69.147.64.97]:26794 "HELO
	smtp124.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752589AbYJEILO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 04:11:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

When building with CONFIG_USB_DEBUG, don't create logspam from
the USB networking drivers.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>

--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -19,6 +19,3 @@ obj-$(CONFIG_USB_NET_ZAURUS)	+= zaurus.o
 obj-$(CONFIG_USB_NET_MCS7830)	+= mcs7830.o
 obj-$(CONFIG_USB_USBNET)	+= usbnet.o
 
-ifeq ($(CONFIG_USB_DEBUG),y)
-EXTRA_CFLAGS += -DDEBUG
-endif

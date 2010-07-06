From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 10/11] isdn/gigaset: document dial-out number format
Date: Tue,  6 Jul 2010 02:19:25 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-10.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:42012 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757096Ab0GFATo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 20:19:44 -0400
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a paragraph to the driver documentation describing how to make
internal and external calls.

Impact: documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/README.gigaset |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/Documentation/isdn/README.gigaset b/Documentation/isdn/README.gigaset
index e472df8..702c046 100644
--- a/Documentation/isdn/README.gigaset
+++ b/Documentation/isdn/README.gigaset
@@ -263,7 +263,22 @@ GigaSet 307x Device Driver
      change its CID mode while the driver is loaded, eg.
         echo 0 > /sys/class/tty/ttyGU0/cidmode
 
-2.7. Unregistered Wireless Devices (M101/M105)
+2.7. Dialing Numbers
+     ---------------
+     The called party number provided by an application for dialing out must
+     be a public network number according to the local dialing plan, without
+     any dial prefix for getting an outside line.
+
+     Internal calls can be made by providing an internal extension number
+     prefixed with "**" (two asterisks) as the called party number. So to dial
+     eg. the first registered DECT handset, give "**11" as the called party
+     number. Dialing "***" (three asterisks) calls all extensions
+     simultaneously (global call).
+
+     This holds for both CAPI 2.0 and ISDN4Linux applications. Unimodem mode
+     does not support internal calls.
+
+2.8. Unregistered Wireless Devices (M101/M105)
      -----------------------------------------
      The main purpose of the ser_gigaset and usb_gigaset drivers is to allow
      the M101 and M105 wireless devices to be used as ISDN devices for ISDN
-- 
1.6.5.3.298.g39add


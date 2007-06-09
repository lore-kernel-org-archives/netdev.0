From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH] net: fix typo in drivers/net/usb/Kconfig
Date: Sun, 10 Jun 2007 00:50:51 +0200
Message-ID: <20070609225051.GA3008@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Massimo Maiurana <maiurana@gmail.com>
To: netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:54558 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756971AbXFIWtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:49:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace invisible character with a space.

The diff looks like this on my terminal:
-        <A0>Choose this option if you're using a host-to-host cable
-        <A0>with one of these chips.
+         Choose this option if you're using a host-to-host cable
+         with one of these chips.

Reported by: Massimo Maiurana <maiurana@gmail.com>

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
Cc: Massimo Maiurana <maiurana@gmail.com>
---
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 3de564b..8dc09a3 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -313,8 +313,8 @@ config USB_KC2190
 	boolean "KT Technology KC2190 based cables (InstaNet)"
 	depends on USB_NET_CDC_SUBSET && EXPERIMENTAL
 	help
-	 =A0Choose this option if you're using a host-to-host cable
-	 =A0with one of these chips.
+	  Choose this option if you're using a host-to-host cable
+	  with one of these chips.
=20
 config USB_NET_ZAURUS
 	tristate "Sharp Zaurus (stock ROMs) and compatible"

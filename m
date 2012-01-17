From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net 1/2] caif: Fix typo in Vendor/Product-ID for CAIF modems
Date: Tue, 17 Jan 2012 14:03:13 +0100
Message-ID: <1326805394-2662-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:48443 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752767Ab2AQND2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 08:03:28 -0500
Received: by lahc1 with SMTP id c1so1502851lah.19
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 05:03:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix typo for the Vendor/Product Id for ST-Ericsson CAIF modems.
Discovery is based on fixed USB vendor 0x04cc (ST-Ericsson),
product-id 0x230f (NCM).

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_usb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_usb.c b/net/caif/caif_usb.c
index 5fc9eca..32ff5f2 100644
--- a/net/caif/caif_usb.c
+++ b/net/caif/caif_usb.c
@@ -27,7 +27,7 @@ MODULE_LICENSE("GPL");
 #define CFUSB_ALIGNMENT 4	/* Number of bytes to align. */
 #define CFUSB_MAX_HEADLEN (CFUSB_PAD_DESCR_SZ + CFUSB_ALIGNMENT-1)
 #define STE_USB_VID 0x04cc	/* USB Product ID for ST-Ericsson */
-#define STE_USB_PID_CAIF 0x2306	/* Product id for CAIF Modems */
+#define STE_USB_PID_CAIF 0x230f	/* Product id for CAIF Modems */
=20
 struct cfusbl {
 	struct cflayer layer;
--=20
1.7.1

From: =?UTF-8?q?S=C3=B8ren=20Holm?= <sgh@sgh.dk>
Subject: [PATCH] asix: Support DLink DUB-E100 H/W Ver C1
Date: Mon, 17 Sep 2012 21:23:20 +0200
Message-ID: <1347909800-3056-1-git-send-email-sgh@sgh.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=B8ren=20Holm?= <sgh@sgh.dk>, stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.stofanet.dk ([212.10.10.12]:37812 "EHLO mx02.stofanet.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932417Ab2IQTbR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 15:31:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: S=C3=B8ren Holm <sgh@sgh.dk>
Cc: stable@vger.kernel.org
---
 drivers/net/usb/asix.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 3ae80ec..12f372e 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1604,6 +1604,10 @@ static const struct usb_device_id	products [] =3D=
 {
 	USB_DEVICE (0x2001, 0x3c05),
 	.driver_info =3D (unsigned long) &ax88772_info,
 }, {
+	// DLink DUB-E100 H/W Ver C1
+	USB_DEVICE (0x2001, 0x1a02),
+	.driver_info =3D (unsigned long) &ax88772_info,
+}, {
 	// Linksys USB1000
 	USB_DEVICE (0x1737, 0x0039),
 	.driver_info =3D (unsigned long) &ax88178_info,
--=20
1.7.10.4

From: =?UTF-8?q?S=C3=B8ren=20Holm?= <sgh@sgh.dk>
Subject: [PATCH] asix: Support DLink DUB-E100 H/W Ver C1
Date: Tue, 18 Sep 2012 09:50:57 +0200
Message-ID: <1347954657-8975-1-git-send-email-sgh@sgh.dk>
References: <CABkLObpU3P84AHTBG1hkrHt_HdaPzdTiRU1ACnJv=Qhb+wYPbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=B8ren=20Holm?= <sgh@sgh.dk>, stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe.ge-0-2-0-950.faaqnqu1.customer.tele.dk ([93.167.193.18]:59235
	"EHLO mail.mikrofyn.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755162Ab2IRIDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 04:03:18 -0400
In-Reply-To: <CABkLObpU3P84AHTBG1hkrHt_HdaPzdTiRU1ACnJv=Qhb+wYPbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: S=C3=B8ren Holm <sgh@sgh.dk>
Cc: stable@vger.kernel.org
---
 drivers/net/usb/asix_devices.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devi=
ces.c
index 4fd48df..32e31c5 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -962,6 +962,10 @@ static const struct usb_device_id	products [] =3D =
{
 	USB_DEVICE (0x2001, 0x3c05),
 	.driver_info =3D (unsigned long) &ax88772_info,
 }, {
+       // DLink DUB-E100 H/W Ver C1
+       USB_DEVICE (0x2001, 0x1a02),
+       .driver_info =3D (unsigned long) &ax88772_info,
+}, {
 	// Linksys USB1000
 	USB_DEVICE (0x1737, 0x0039),
 	.driver_info =3D (unsigned long) &ax88178_info,
--=20
1.7.10.4

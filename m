From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH 2/3] net: qmi_wwan: add Option GTM681W
Date: Fri, 28 Jun 2013 17:17:50 +0200
Message-ID: <1372432671-17283-2-git-send-email-bjorn@mork.no>
References: <1372432671-17283-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:42815 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755293Ab3F1PR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jun 2013 11:17:56 -0400
In-Reply-To: <1372432671-17283-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A standard Gobi 3000 reference design module.

Reported-by: Richard Weinberger <richard@nod.at>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 1d1021c..e4a0843 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -612,6 +612,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_GOBI_DEVICE(0x05c6, 0x9265)},	/* Asus Gobi 2000 Modem device (VR=
305) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9235)},	/* Top Global Gobi 2000 Modem devi=
ce (VR306) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9275)},	/* iRex Technologies Gobi 2000 Mod=
em device (VR307) */
+	{QMI_GOBI_DEVICE(0x0af0, 0x8120)},	/* Option GTM681W */
 	{QMI_GOBI_DEVICE(0x1199, 0x68a5)},	/* Sierra Wireless Modem */
 	{QMI_GOBI_DEVICE(0x1199, 0x68a9)},	/* Sierra Wireless Modem */
 	{QMI_GOBI_DEVICE(0x1199, 0x9001)},	/* Sierra Wireless Gobi 2000 Modem=
 device (VT773) */
--=20
1.7.10.4

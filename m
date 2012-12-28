From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: qmi_wwan: add Telekom Speedstick LTE II
Date: Fri, 28 Dec 2012 17:30:55 +0100
Message-ID: <1356712255-9488-1-git-send-email-bjorn@mork.no>
References: <50D6CF0A.9020300@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer@t-online.de>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54607 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753685Ab2L1QbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 11:31:12 -0500
In-Reply-To: <50D6CF0A.9020300@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

also known as Alcatel One Touch L100V LTE

The driver description files gives these names to the vendor specific
functions on this modem:

 Application1: VID_1BBB&PID_011E&MI_00
 Application2: VID_1BBB&PID_011E&MI_01
 Modem:        VID_1BBB&PID_011E&MI_03
 Ethernet:     VID_1BBB&PID_011E&MI_04

Reported-by: Thomas Sch=C3=A4fer <tschaefer@t-online.de>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 91d7cb9..6a1ca50 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -458,6 +458,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 8)},	/* Sierra Wireless MC7710 in QMI=
 mode */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in QM=
I mode */
 	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 */
+	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (Al=
catel One Touch L100V LTE) */
=20
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
--=20
1.7.10.4

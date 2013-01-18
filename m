From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net] net: qmi_wwan: add ONDA MT8205 4G LTE
Date: Fri, 18 Jan 2013 15:26:34 +0100
Message-ID: <1358519194-10118-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:44756 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755285Ab3ARO0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 09:26:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver description files gives these names to the vendor specific
functions on this modem:

 Diag   VID_19D2&PID_0265&MI_00
 NMEA   VID_19D2&PID_0265&MI_01
 AT cmd VID_19D2&PID_0265&MI_02
 Modem  VID_19D2&PID_0265&MI_03
 Net    VID_19D2&PID_0265&MI_04

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index c434108..575a583 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -433,6 +433,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x19d2, 0x0199, 1)},	/* ZTE MF820S */
 	{QMI_FIXED_INTF(0x19d2, 0x0200, 1)},
 	{QMI_FIXED_INTF(0x19d2, 0x0257, 3)},	/* ZTE MF821 */
+	{QMI_FIXED_INTF(0x19d2, 0x0265, 4)},	/* ONDA MT8205 4G LTE */
 	{QMI_FIXED_INTF(0x19d2, 0x0284, 4)},	/* ZTE MF880 */
 	{QMI_FIXED_INTF(0x19d2, 0x0326, 4)},	/* ZTE MF821D */
 	{QMI_FIXED_INTF(0x19d2, 0x1008, 4)},	/* ZTE (Vodafone) K3570-Z */
--=20
1.7.10.4

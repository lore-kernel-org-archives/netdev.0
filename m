From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net] net: qmi_wwan: add ZTE MF880
Date: Wed, 19 Dec 2012 15:15:51 +0100
Message-ID: <1355926551-30316-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57809 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755173Ab2LSOQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 09:16:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver description files gives these names to the vendor specific
functions on this modem:

 diag: VID_19D2&PID_0284&MI_00
 nmea: VID_19D2&PID_0284&MI_01
 at:   VID_19D2&PID_0284&MI_02
 mdm:  VID_19D2&PID_0284&MI_03
 net:  VID_19D2&PID_0284&MI_04

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 9b950f5..91d7cb9 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -433,6 +433,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x19d2, 0x0199, 1)},	/* ZTE MF820S */
 	{QMI_FIXED_INTF(0x19d2, 0x0200, 1)},
 	{QMI_FIXED_INTF(0x19d2, 0x0257, 3)},	/* ZTE MF821 */
+	{QMI_FIXED_INTF(0x19d2, 0x0284, 4)},	/* ZTE MF880 */
 	{QMI_FIXED_INTF(0x19d2, 0x0326, 4)},	/* ZTE MF821D */
 	{QMI_FIXED_INTF(0x19d2, 0x1008, 4)},	/* ZTE (Vodafone) K3570-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x1010, 4)},	/* ZTE (Vodafone) K3571-Z */
--=20
1.7.10.4

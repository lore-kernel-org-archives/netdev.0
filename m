From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net] net: qmi_wwan: adding more ZTE devices
Date: Thu, 18 Oct 2012 17:11:29 +0200
Message-ID: <1350573090-9345-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54298 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756225Ab2JRPLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 11:11:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Analyzed a few Windows driver description files, supporting
this long list of devices:

%ztewwan.DeviceDesc0002%    =3D ztewwan.ndi, USB\VID_19D2&PID_0002&MI_0=
1
%ztewwan.DeviceDesc0012%    =3D ztewwan.ndi, USB\VID_19D2&PID_0012&MI_0=
1
%ztewwan.DeviceDesc0017%    =3D ztewwan.ndi, USB\VID_19D2&PID_0017&MI_0=
3
%ztewwan.DeviceDesc0021%    =3D ztewwan.ndi, USB\VID_19D2&PID_0021&MI_0=
4
%ztewwan.DeviceDesc0025%    =3D ztewwan.ndi, USB\VID_19D2&PID_0025&MI_0=
1
%ztewwan.DeviceDesc0031%    =3D ztewwan.ndi, USB\VID_19D2&PID_0031&MI_0=
4
%ztewwan.DeviceDesc0042%    =3D ztewwan.ndi, USB\VID_19D2&PID_0042&MI_0=
4
%ztewwan.DeviceDesc0049%    =3D ztewwan.ndi, USB\VID_19D2&PID_0049&MI_0=
5
%ztewwan.DeviceDesc0052%    =3D ztewwan.ndi, USB\VID_19D2&PID_0052&MI_0=
4
%ztewwan.DeviceDesc0055%    =3D ztewwan.ndi, USB\VID_19D2&PID_0055&MI_0=
1
%ztewwan.DeviceDesc0058%    =3D ztewwan.ndi, USB\VID_19D2&PID_0058&MI_0=
4
%ztewwan.DeviceDesc0063%    =3D ztewwan.ndi, USB\VID_19D2&PID_0063&MI_0=
4
%ztewwan.DeviceDesc2002%    =3D ztewwan.ndi, USB\VID_19D2&PID_2002&MI_0=
4
%ztewwan.DeviceDesc0104%    =3D ztewwan.ndi, USB\VID_19D2&PID_0104&MI_0=
4
%ztewwan.DeviceDesc0113%    =3D ztewwan.ndi, USB\VID_19D2&PID_0113&MI_0=
5
%ztewwan.DeviceDesc0118%    =3D ztewwan.ndi, USB\VID_19D2&PID_0118&MI_0=
5
%ztewwan.DeviceDesc0121%    =3D ztewwan.ndi, USB\VID_19D2&PID_0121&MI_0=
5
%ztewwan.DeviceDesc0123%    =3D ztewwan.ndi, USB\VID_19D2&PID_0123&MI_0=
4
%ztewwan.DeviceDesc0124%    =3D ztewwan.ndi, USB\VID_19D2&PID_0124&MI_0=
5
%ztewwan.DeviceDesc0125%    =3D ztewwan.ndi, USB\VID_19D2&PID_0125&MI_0=
6
%ztewwan.DeviceDesc0126%    =3D ztewwan.ndi, USB\VID_19D2&PID_0126&MI_0=
5
%ztewwan.DeviceDesc1008%    =3D ztewwan.ndi, USB\VID_19D2&PID_1008&MI_0=
4
%ztewwan.DeviceDesc1010%    =3D ztewwan.ndi, USB\VID_19D2&PID_1010&MI_0=
4
%ztewwan.DeviceDesc1012%    =3D ztewwan.ndi, USB\VID_19D2&PID_1012&MI_0=
4
%ztewwan.DeviceDesc1402%    =3D ztewwan.ndi, USB\VID_19D2&PID_1402&MI_0=
2
%ztewwan.DeviceDesc0157%    =3D ztewwan.ndi, USB\VID_19D2&PID_0157&MI_0=
5
%ztewwan.DeviceDesc0158%    =3D ztewwan.ndi, USB\VID_19D2&PID_0158&MI_0=
3
%ztewwan.DeviceDesc1401%    =3D ztewwan.ndi, USB\VID_19D2&PID_1401&MI_0=
2
%ztewwan.DeviceDesc0130%    =3D ztewwan.ndi, USB\VID_19D2&PID_0130&MI_0=
1
%ztewwan.DeviceDesc0133%    =3D ztewwan.ndi, USB\VID_19D2&PID_0133&MI_0=
3
%ztewwan.DeviceDesc0176%    =3D ztewwan.ndi, USB\VID_19D2&PID_0176&MI_0=
3
%ztewwan.DeviceDesc0178%    =3D ztewwan.ndi, USB\VID_19D2&PID_0178&MI_0=
3
%ztewwan.DeviceDesc0168%    =3D ztewwan.ndi, USB\VID_19D2&PID_0168&MI_0=
4
;EuFi890
%ztewwan.DeviceDesc0191%    =3D ztewwan.ndi, USB\VID_19D2&PID_0191&MI_0=
4
;AL621
%ztewwan.DeviceDesc0167%    =3D ztewwan.ndi, USB\VID_19D2&PID_0167&MI_0=
4
;MF821
%ztewwan.DeviceDesc0199%    =3D ztewwan.ndi, USB\VID_19D2&PID_0199&MI_0=
1
%ztewwan.DeviceDesc0200%    =3D ztewwan.ndi, USB\VID_19D2&PID_0200&MI_0=
1
%ztewwan.DeviceDesc0257%    =3D ztewwan.ndi, USB\VID_19D2&PID_0257&MI_0=
3
;MF821V
%ztewwan.DeviceDesc1018%    =3D ztewwan.ndi, USB\VID_19D2&PID_1018&MI_0=
3
;MF91
%ztewwan.DeviceDesc1426%    =3D ztewwan.ndi, USB\VID_19D2&PID_1426&MI_0=
2
;0141
%ztewwan.DeviceDesc1247%    =3D ztewwan.ndi, USB\VID_19D2&PID_1247&MI_0=
4
%ztewwan.DeviceDesc1425%    =3D ztewwan.ndi, USB\VID_19D2&PID_1425&MI_0=
2
%ztewwan.DeviceDesc1424%    =3D ztewwan.ndi, USB\VID_19D2&PID_1424&MI_0=
2
%ztewwan.DeviceDesc1252%    =3D ztewwan.ndi, USB\VID_19D2&PID_1252&MI_0=
4
%ztewwan.DeviceDesc1254%    =3D ztewwan.ndi, USB\VID_19D2&PID_1254&MI_0=
4
%ztewwan.DeviceDesc1255A%   =3D ztewwan.ndi, USB\VID_19D2&PID_1255&MI_0=
3
%ztewwan.DeviceDesc1255B%   =3D ztewwan.ndi, USB\VID_19D2&PID_1255&MI_0=
4
%ztewwan.DeviceDesc1256%    =3D ztewwan.ndi, USB\VID_19D2&PID_1256&MI_0=
4
%ztewwan.DeviceDesc1245%    =3D ztewwanCombB.ndi, USB\VID_19D2&PID_1245=
&MI_04
%ztewwan.DeviceDesc1021%    =3D ztewwan.ndi, USB\VID_19D2&PID_1021&MI_0=
2

Adding the ones we were missing.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |   41 ++++++++++++++++++++++++++++++++++++=
+++++
 1 file changed, 41 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 6883c37..9d23ba2 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -371,16 +371,57 @@ static const struct usb_device_id products[] =3D =
{
 	},
=20
 	/* 3. Combined interface devices matching on interface number */
+	{QMI_FIXED_INTF(0x19d2, 0x0002, 1)},
+	{QMI_FIXED_INTF(0x19d2, 0x0012, 1)},
+	{QMI_FIXED_INTF(0x19d2, 0x0017, 3)},
+	{QMI_FIXED_INTF(0x19d2, 0x0021, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x0025, 1)},
+	{QMI_FIXED_INTF(0x19d2, 0x0031, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x0042, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x0049, 5)},
+	{QMI_FIXED_INTF(0x19d2, 0x0052, 4)},
 	{QMI_FIXED_INTF(0x19d2, 0x0055, 1)},	/* ZTE (Vodafone) K3520-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x0058, 4)},
 	{QMI_FIXED_INTF(0x19d2, 0x0063, 4)},	/* ZTE (Vodafone) K3565-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x0104, 4)},	/* ZTE (Vodafone) K4505-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x0113, 5)},
+	{QMI_FIXED_INTF(0x19d2, 0x0118, 5)},
+	{QMI_FIXED_INTF(0x19d2, 0x0121, 5)},
+	{QMI_FIXED_INTF(0x19d2, 0x0123, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x0124, 5)},
+	{QMI_FIXED_INTF(0x19d2, 0x0125, 6)},
+	{QMI_FIXED_INTF(0x19d2, 0x0126, 5)},
+	{QMI_FIXED_INTF(0x19d2, 0x0130, 1)},
+	{QMI_FIXED_INTF(0x19d2, 0x0133, 3)},
+	{QMI_FIXED_INTF(0x19d2, 0x0141, 5)},
 	{QMI_FIXED_INTF(0x19d2, 0x0157, 5)},	/* ZTE MF683 */
+	{QMI_FIXED_INTF(0x19d2, 0x0158, 3)},
 	{QMI_FIXED_INTF(0x19d2, 0x0167, 4)},	/* ZTE MF820D */
+	{QMI_FIXED_INTF(0x19d2, 0x0168, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x0176, 3)},
+	{QMI_FIXED_INTF(0x19d2, 0x0178, 3)},
+	{QMI_FIXED_INTF(0x19d2, 0x0191, 4)},	/* ZTE EuFi890 */
+	{QMI_FIXED_INTF(0x19d2, 0x0199, 1)},	/* ZTE MF820S */
+	{QMI_FIXED_INTF(0x19d2, 0x0200, 1)},
+	{QMI_FIXED_INTF(0x19d2, 0x0257, 3)},	/* ZTE MF821 */
 	{QMI_FIXED_INTF(0x19d2, 0x0326, 4)},	/* ZTE MF821D */
 	{QMI_FIXED_INTF(0x19d2, 0x1008, 4)},	/* ZTE (Vodafone) K3570-Z */
 	{QMI_FIXED_INTF(0x19d2, 0x1010, 4)},	/* ZTE (Vodafone) K3571-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x1012, 4)},
 	{QMI_FIXED_INTF(0x19d2, 0x1018, 3)},	/* ZTE (Vodafone) K5006-Z */
+	{QMI_FIXED_INTF(0x19d2, 0x1021, 2)},
+	{QMI_FIXED_INTF(0x19d2, 0x1245, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x1247, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x1252, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x1254, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x1255, 3)},
+	{QMI_FIXED_INTF(0x19d2, 0x1255, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x1256, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x1401, 2)},
 	{QMI_FIXED_INTF(0x19d2, 0x1402, 2)},	/* ZTE MF60 */
+	{QMI_FIXED_INTF(0x19d2, 0x1424, 2)},
+	{QMI_FIXED_INTF(0x19d2, 0x1425, 2)},
+	{QMI_FIXED_INTF(0x19d2, 0x1426, 2)},	/* ZTE MF91 */
 	{QMI_FIXED_INTF(0x19d2, 0x2002, 4)},	/* ZTE (Vodafone) K3765-Z */
 	{QMI_FIXED_INTF(0x0f3d, 0x68a2, 8)},    /* Sierra Wireless MC7700 */
 	{QMI_FIXED_INTF(0x114f, 0x68a2, 8)},    /* Sierra Wireless MC7750 */
--=20
1.7.10.4

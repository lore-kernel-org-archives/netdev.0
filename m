From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable] qmi_wwan: add "D-Link DWM-221 B1" device id
Date: Mon, 28 Mar 2016 22:38:16 +0200
Message-ID: <1459197496-11236-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Thomas=20Sch=C3=A4fer?= <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thomas reports:
"Windows:

00 diagnostics
01 modem
02 at-port
03 nmea
04 nic

Linux:

T:  Bus=3D02 Lev=3D01 Prnt=3D01 Port=3D03 Cnt=3D01 Dev#=3D  4 Spd=3D480=
 MxCh=3D 0
D:  Ver=3D 2.00 Cls=3D00(>ifc ) Sub=3D00 Prot=3D00 MxPS=3D64 #Cfgs=3D  =
1
P:  Vendor=3D2001 ProdID=3D7e19 Rev=3D02.32
S:  Manufacturer=3DMobile Connect
S:  Product=3DMobile Connect
S:  SerialNumber=3D0123456789ABCDEF
C:  #Ifs=3D 6 Cfg#=3D 1 Atr=3Da0 MxPwr=3D500mA
I:  If#=3D 0 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Doption
I:  If#=3D 1 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3D00 Prot=3D00 Driv=
er=3Doption
I:  If#=3D 2 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3D00 Prot=3D00 Driv=
er=3Doption
I:  If#=3D 3 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3D00 Prot=3D00 Driv=
er=3Doption
I:  If#=3D 4 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Driv=
er=3Dqmi_wwan
I:  If#=3D 5 Alt=3D 0 #EPs=3D 2 Cls=3D08(stor.) Sub=3D06 Prot=3D50 Driv=
er=3Dusb-storage"

Reported-by: Thomas Sch=C3=A4fer <tschaefer-zqRNUXuvxA0b1SvskN2V4Q@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 7d717c66bcb0..9d1fce8a6e84 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -844,6 +844,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x19d2, 0x1426, 2)},	/* ZTE MF91 */
 	{QMI_FIXED_INTF(0x19d2, 0x1428, 2)},	/* Telewell TW-LTE 4G v2 */
 	{QMI_FIXED_INTF(0x19d2, 0x2002, 4)},	/* ZTE (Vodafone) K3765-Z */
+	{QMI_FIXED_INTF(0x2001, 0x7e19, 4)},	/* D-Link DWM-221 B1 */
 	{QMI_FIXED_INTF(0x0f3d, 0x68a2, 8)},    /* Sierra Wireless MC7700 */
 	{QMI_FIXED_INTF(0x114f, 0x68a2, 8)},    /* Sierra Wireless MC7750 */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 8)},	/* Sierra Wireless MC7710 in QMI=
 mode */
--=20
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

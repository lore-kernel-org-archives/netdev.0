From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] kaweth - Psion Gold Port
Date: Fri, 10 Dec 2004 16:54:51 +0100
Message-ID: <aec7e5c3041210075412e287ba@mail.gmail.com>
Reply-To: Magnus Damm <magnus.damm@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_937_10448295.1102694091939"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_Part_937_10448295.1102694091939
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

This little patch adds support for "Psion Dacom Gold Port Ethernet" to kaweth.

Please apply.

/ magnus

------=_Part_937_10448295.1102694091939
Content-Type: text/x-patch; name="linux-2.6.9-goldport.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="linux-2.6.9-goldport.patch"

--- linux-2.6.9/drivers/usb/net/kaweth.c=092004-12-10 16:31:51.677492360 +0=
100
+++ linux-2.6.9-goldport/drivers/usb/net/kaweth.c=092004-12-10 16:31:49.517=
820680 +0100
@@ -160,6 +160,7 @@
 =09{ USB_DEVICE(0x1342, 0x0204) }, /* Mobility USB-Ethernet Adapter */
 =09{ USB_DEVICE(0x13d2, 0x0400) }, /* Shark Pocket Adapter */
 =09{ USB_DEVICE(0x1485, 0x0001) },=09/* Silicom U2E */
+=09{ USB_DEVICE(0x1485, 0x0002) }, /* Psion Dacom Gold Port Ethernet */
 =09{ USB_DEVICE(0x1645, 0x0005) }, /* Entrega E45 */
 =09{ USB_DEVICE(0x1645, 0x0008) }, /* Entrega USB Ethernet Adapter */
 =09{ USB_DEVICE(0x1645, 0x8005) }, /* PortGear Ethernet Adapter */

------=_Part_937_10448295.1102694091939--

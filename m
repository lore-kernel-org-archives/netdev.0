From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: [PATCH] ACX: Delete .owner field in usb.c
Date: Fri, 10 Feb 2006 22:46:02 +0100
Message-ID: <200602102246.02307.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

diff-tree e0f5be38b5dea8bbfc486edbf9d88d5ee94941d9 (from=20
29292af943e12ace0115497616569f0629ed1cd7)
Author: Carlos <carlos@pepe.(none)>
Date:   Fri Feb 10 21:02:39 2006 +0000

    Delete .owner field in usb.c
   =20
    It's no longer there. We already deleted it. Andi, I'm looking at you...

diff --git a/usb.c b/usb.c
index 45a95dd..1e64b15 100644
=2D-- a/usb.c
+++ b/usb.c
@@ -155,7 +155,6 @@ MODULE_DEVICE_TABLE(usb, acxusb_ids);
 /* USB driver data structure as required by the kernel's USB core */
 static struct usb_driver
 acxusb_driver =3D {
=2D	.owner =3D THIS_MODULE,
 	.name =3D "acx_usb",
 	.probe =3D acxusb_e_probe,
 	.disconnect =3D acxusb_e_disconnect,

=2D-=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642

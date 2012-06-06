From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH] net: sierra_net: device IDs for Aircard 320U++
Date: Wed,  6 Jun 2012 09:18:10 +0200
Message-ID: <1338967090-7119-1-git-send-email-bjorn@mork.no>
References: <20120605212414.GB6526@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	linux-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org, Autif Khan <autif.mlist-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Tom Cassidy <tomas.cassidy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120605212414.GB6526-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding device IDs for Aircard 320U and two other devices
found in the out-of-tree version of this driver.

Cc: linux-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org
Cc: Autif Khan <autif.mlist-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Tom Cassidy <tomas.cassidy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/sierra_net.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.=
c
index 3faef56..d75d1f5 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -946,7 +946,7 @@ struct sk_buff *sierra_net_tx_fixup(struct usbnet *=
dev, struct sk_buff *skb,
 }
=20
 static const u8 sierra_net_ifnum_list[] =3D { 7, 10, 11 };
-static const struct sierra_net_info_data sierra_net_info_data_68A3 =3D=
 {
+static const struct sierra_net_info_data sierra_net_info_data_direct_i=
p =3D {
 	.rx_urb_size =3D 8 * 1024,
 	.whitelist =3D {
 		.infolen =3D ARRAY_SIZE(sierra_net_ifnum_list),
@@ -954,7 +954,7 @@ static const struct sierra_net_info_data sierra_net=
_info_data_68A3 =3D {
 	}
 };
=20
-static const struct driver_info sierra_net_info_68A3 =3D {
+static const struct driver_info sierra_net_info_direct_ip =3D {
 	.description =3D "Sierra Wireless USB-to-WWAN Modem",
 	.flags =3D FLAG_WWAN | FLAG_SEND_ZLP,
 	.bind =3D sierra_net_bind,
@@ -962,12 +962,18 @@ static const struct driver_info sierra_net_info_6=
8A3 =3D {
 	.status =3D sierra_net_status,
 	.rx_fixup =3D sierra_net_rx_fixup,
 	.tx_fixup =3D sierra_net_tx_fixup,
-	.data =3D (unsigned long)&sierra_net_info_data_68A3,
+	.data =3D (unsigned long)&sierra_net_info_data_direct_ip,
 };
=20
 static const struct usb_device_id products[] =3D {
 	{USB_DEVICE(0x1199, 0x68A3), /* Sierra Wireless USB-to-WWAN modem */
-	.driver_info =3D (unsigned long) &sierra_net_info_68A3},
+	.driver_info =3D (unsigned long) &sierra_net_info_direct_ip},
+	{USB_DEVICE(0x0F3D, 0x68A3), /* AT&T Direct IP modem */
+	.driver_info =3D (unsigned long) &sierra_net_info_direct_ip},
+	{USB_DEVICE(0x1199, 0x68AA), /* Sierra Wireless Direct IP LTE modem *=
/
+	.driver_info =3D (unsigned long) &sierra_net_info_direct_ip},
+	{USB_DEVICE(0x0F3D, 0x68AA), /* AT&T Direct IP LTE modem */
+	.driver_info =3D (unsigned long) &sierra_net_info_direct_ip},
=20
 	{}, /* last item */
 };
--=20
1.7.10

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

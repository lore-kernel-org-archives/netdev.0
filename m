From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: BUG: rt2x00usb: Vendor Request 0x07 failed
Date: Sat, 20 Aug 2011 10:42:12 +0200
Message-ID: <4E4F7364.2060609@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF6C5B7397CA007367ABA40D4"
Cc: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Gertjan van Wingerde <gwingerde-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF6C5B7397CA007367ABA40D4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

I'm a running a sheeva plug (ARM/kirkwood) with a rt2800 USB stick in AP =
mode.
Bus 001 Device 002: ID 1737:0071 Linksys WUSB600N v1 Dual-Band Wireless-N=
 Network Adapter [Ralink RT2870]

kernel is v3.0.3 +
http://www.spinics.net/lists/linux-wireless/msg74377.html
(see http://git.pengutronix.de/?p=3Dmkl/linux-2.6.git;a=3Dshortlog;h=3Dre=
fs/heads/wireless/rt2x00/v3.0.3)

With the patch the oops is gone, but after a few hours it fails with:

[30971.764840] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x0438 with error -71.
[30975.519840] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x06 failed for offset 0x0408 with error -71.
[30978.890840] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x06 failed for offset 0x0408 with error -71.
[30982.389845] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x0438 with error -71.
[30987.200842] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x101c with error -71.
[30990.795843] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x101c with error -71.
=2E..
[31306.426842] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x101c with error -71.
[31306.437366] phy0 -> rt2x00usb_regbusy_read: Error - Indirect register =
access failed: offset=3D0x0000101c, value=3D0xc003ec28
[31309.647841] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x06 failed for offset 0x6888 with error -71.
=2E.
[31838.105841] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x101c with error -71.
[31838.116386] phy0 -> rt2x00usb_regbusy_read: Error - Indirect register =
access failed: offset=3D0x0000101c, value=3D0xc003ec28
[31841.327840] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x101c with error -71.
=2E..
[32043.619842] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x101c with error -71.
[32046.830843] phy0 -> rt2x00usb_vendor_request: Error - Vendor Request 0=
x07 failed for offset 0x101c with error -71.
[32048.956352] INFO: task hostapd:1499 blocked for more than 120 seconds.=

[32048.962920] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disable=
s this message.
[32048.970801] hostapd         D c02d85e0     0  1499      1 0x00000000
[32048.977234] [<c02d85e0>] (schedule+0x478/0x4e8) from [<c02d9370>] (__m=
utex_lock_slowpath+0x64/0x88)
[32048.986352] [<c02d9370>] (__mutex_lock_slowpath+0x64/0x88) from [<bf37=
8f5c>] (rt2x00usb_vendor_request_buff+0x24/0xb8 [rt2x00usb])
[32048.998185] [<bf378f5c>] (rt2x00usb_vendor_request_buff+0x24/0xb8 [rt2=
x00usb]) from [<bf38d034>] (rt2x00usb_register_read+0x34/0x44 [rt2800usb]=
)
[32049.011243] [<bf38d034>] (rt2x00usb_register_read+0x34/0x44 [rt2800usb=
]) from [<bf381d74>] (rt2800_config_shared_key+0xc4/0x11c [rt2800lib])
[32049.023958] [<bf381d74>] (rt2800_config_shared_key+0xc4/0x11c [rt2800l=
ib]) from [<bf36aac0>] (rt2x00mac_set_key+0x138/0x14c [rt2x00lib])
[32049.036410] [<bf36aac0>] (rt2x00mac_set_key+0x138/0x14c [rt2x00lib]) f=
rom [<bf34379c>] (ieee80211_key_disable_hw_accel+0x80/0xd0 [mac80211])
[32049.049221] [<bf34379c>] (ieee80211_key_disable_hw_accel+0x80/0xd0 [ma=
c80211]) from [<bf343810>] (__ieee80211_key_destroy+0x24/0x6c [mac80211])=

[32049.062285] [<bf343810>] (__ieee80211_key_destroy+0x24/0x6c [mac80211]=
) from [<bf343bf4>] (ieee80211_key_link+0x10c/0x134 [mac80211])
[32049.074471] [<bf343bf4>] (ieee80211_key_link+0x10c/0x134 [mac80211]) f=
rom [<bf33c3f8>] (ieee80211_add_key+0x104/0x130 [mac80211])
[32049.086392] [<bf33c3f8>] (ieee80211_add_key+0x104/0x130 [mac80211]) fr=
om [<bf306cc8>] (nl80211_new_key+0xec/0x110 [cfg80211])
[32049.097834] [<bf306cc8>] (nl80211_new_key+0xec/0x110 [cfg80211]) from =
[<c027542c>] (genl_rcv_msg+0x1bc/0x204)
[32049.107835] [<c027542c>] (genl_rcv_msg+0x1bc/0x204) from [<c02748e0>] =
(netlink_rcv_skb+0x50/0xac)
[32049.116769] [<c02748e0>] (netlink_rcv_skb+0x50/0xac) from [<c0275264>]=
 (genl_rcv+0x18/0x24)
[32049.125172] [<c0275264>] (genl_rcv+0x18/0x24) from [<c02742ac>] (netli=
nk_unicast+0x230/0x2cc)
[32049.133754] [<c02742ac>] (netlink_unicast+0x230/0x2cc) from [<c027466c=
>] (netlink_sendmsg+0x28c/0x324)
[32049.143132] [<c027466c>] (netlink_sendmsg+0x28c/0x324) from [<c0242a78=
>] (sock_sendmsg+0xac/0xd4)
[32049.152067] [<c0242a78>] (sock_sendmsg+0xac/0xd4) from [<c0243d50>] (_=
_sys_sendmsg+0x1c4/0x258)
[32049.160829] [<c0243d50>] (__sys_sendmsg+0x1c4/0x258) from [<c0244830>]=
 (sys_sendmsg+0x3c/0x60)
[32049.169510] [<c0244830>] (sys_sendmsg+0x3c/0x60) from [<c002fbc0>] (re=
t_fast_syscall+0x0/0x2c)

The vendor requests 0x06 and 0x07 keep failing with some rt2x00usb_regbus=
y_read.

cheers,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigF6C5B7397CA007367ABA40D4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5Pc2QACgkQjTAFq1RaXHMSFACfSupX4PDPKzZxrJmzwyew5B8C
79sAn1AApNkGSbVQJU8jm0wV8miuqg7f
=UUcI
-----END PGP SIGNATURE-----

--------------enigF6C5B7397CA007367ABA40D4--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

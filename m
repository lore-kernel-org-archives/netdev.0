From: Johannes Berg <johannes@sipsolutions.net>
Subject: wireless-dev: warnings while removing bcm43xx-d80211
Date: Sat, 29 Apr 2006 13:00:25 +0200
Message-ID: <1146308425.5019.38.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-flcGHtbS8Iq5I3wtH4vK"
Cc: Broadcom Linux <bcm43xx-dev@berlios.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47011 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750700AbWD2LAg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 07:00:36 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-flcGHtbS8Iq5I3wtH4vK
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

This didn't look too good to me, maybe someone can investigate?

[24070.841580] Badness in remove_proc_entry at fs/proc/generic.c:732
[24070.841593] Call Trace:
[24070.841598] [E9A87C30] [C00081E8] show_stack+0x50/0x190 (unreliable)
[24070.841618] [E9A87C60] [C000E4EC] program_check_exception+0x454/0x5d0
[24070.841632] [E9A87CC0] [C000FA00] ret_from_except_full+0x0/0x4c
[24070.841643] --- Exception: 700 at remove_proc_entry+0x14c/0x1d0
[24070.841661]     LR =3D remove_proc_entry+0x58/0x1d0
[24070.841667] [E9A87DC0] [F20BE214] ieee80211_proc_deinit_interface+0x38/0=
xe4 [80211]
[24070.841729] [E9A87DD0] [F20B17E0] ieee80211_unregister_hw+0xf4/0x1ac [80=
211]
[24070.841749] [E9A87DF0] [F24C2644] bcm43xx_remove_one+0x44/0xc0 [bcm43xx_=
d80211]
[24070.841789] [E9A87E10] [C0151670] pci_device_remove+0x38/0x60
[24070.841806] [E9A87E20] [C019F098] __device_release_driver+0x74/0xac
[24070.841822] [E9A87E40] [C019F5DC] driver_detach+0x110/0x140
[24070.841833] [E9A87E60] [C019E8C8] bus_remove_driver+0x8c/0xc8
[24070.841844] [E9A87E80] [C019F990] driver_unregister+0x18/0x34
[24070.841855] [E9A87EA0] [C0151524] pci_unregister_driver+0x20/0x8c
[24070.841866] [E9A87EC0] [F24D9954] bcm43xx_exit+0x18/0x376c [bcm43xx_d802=
11]
[24070.841886] [E9A87ED0] [C0047D30] sys_delete_module+0x19c/0x20c
[24070.841899] [E9A87F40] [C000F3A4] ret_from_syscall+0x0/0x38
[24070.841909] --- Exception: c01 at 0xff6e708
[24070.841918]     LR =3D 0x1000103c
[24084.097041] Badness in remove_proc_entry at fs/proc/generic.c:732
[24084.097056] Call Trace:
[24084.097061] [E9BDBD20] [C00081E8] show_stack+0x50/0x190 (unreliable)
[24084.097081] [E9BDBD50] [C000E4EC] program_check_exception+0x454/0x5d0
[24084.097095] [E9BDBDB0] [C000FA00] ret_from_except_full+0x0/0x4c
[24084.097106] --- Exception: 700 at remove_proc_entry+0x14c/0x1d0
[24084.097124]     LR =3D remove_proc_entry+0x58/0x1d0
[24084.097130] [E9BDBEB0] [F20BE37C] ieee80211_proc_deinit+0x38/0x48 [80211=
]
[24084.097174] [E9BDBEC0] [F20C7560] ieee80211_exit+0x14/0x3aec [80211]
[24084.097192] [E9BDBED0] [C0047D30] sys_delete_module+0x19c/0x20c
[24084.097206] [E9BDBF40] [C000F3A4] ret_from_syscall+0x0/0x38
[24084.097215] --- Exception: c01 at 0xff6e708
[24084.097224]     LR =3D 0x1000103c


--=-flcGHtbS8Iq5I3wtH4vK
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARFNHR6Vg1VMiehFYAQLB6g//XM1FoIknHSpftYOSkz2RyR9aOox/5BCP
0N+8Unk+ySKjv22HTJ8t8jk6HvwfNwsM3zKiA2uXyoQ9gTcwLXEap6aVjCiZdPXU
hjLBPL7KuaGaEh1c/Cc0edEbb5vfBZGfYGx2R2MbIFxndoNpGMYzCXYcoJzNQEny
Ueb7A1FMLM53CWZR4p6Xj+Nh972zq+LlhGORinYcnMGO/rNajFSfkYUKf+70aGQ7
CQ3Ccvg0XkPj4TEi8OAFVLVNkoDVNoPHHYOJb5YBV5b88jGi7pWNLZP0olUfhk4r
lMTtiEYIksUaaQuWlnnlpdECoZYSMBv3JrdJssR0xzPjlGVvsPhWgJGLEDEGusEy
MPPRmb/uv39aAZZv+mcqvDhpKRcb/vPLqPdIKLjvT3znzg0hderv4oMewR4Jggeb
tPOEfBa7CuM+jaV39D40eY3DkZDWESok+M+vIoYoQ2m2eO/T6V4VzIq7K50OG9Fa
X3Vpn4POQG0JRYvBrPZG3LcqYED/kG4MFlzDpOOYpjj7NrzlgGCWUJyzobznlfwz
VrG8lppKldGlEHrtfHM66TZ+Fgb5UgaYlKJVkR9R5wq6isKUzlkBtaYPySSbwEVV
l9gyZwFUVZk5lFm9P+C998SpX1n6zfcW/aqoRKNx4bCPiexboVI0wMoSCJlXR3P8
0b7mSg5XrHI=
=tBfU
-----END PGP SIGNATURE-----

--=-flcGHtbS8Iq5I3wtH4vK--


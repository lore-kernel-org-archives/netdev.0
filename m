From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Tue, 20 Dec 2011 13:02:31 +1100
Message-ID: <20111220130231.b819d888246ce08a4660eaa4@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__20_Dec_2011_13_02_31_+1100_74=Gb_Gk/nTJvZ4."
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mat Martineau <mathewm@codeaurora.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Andrei Emeltchenko <andrei.emeltchenko@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__20_Dec_2011_13_02_31_+1100_74=Gb_Gk/nTJvZ4.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/bluetooth/l2cap_core.c between commit 36e999a83a4a ("Bluetooth:
Prevent uninitialized data access in L2CAP configuration") from the
wireless tree and commit 66af7aaf9edf ("Bluetooth: EFS: parse L2CAP
config response") from the net-next tree.

Just context changes.  I fixed it up (see below) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/bluetooth/l2cap_core.c
index 17b5b1c,014fdec..0000000
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@@ -2152,7 -2372,8 +2372,8 @@@ static int l2cap_parse_conf_rsp(struct=20
  	void *ptr =3D req->data;
  	int type, olen;
  	unsigned long val;
 -	struct l2cap_conf_rfc rfc;
 +	struct l2cap_conf_rfc rfc =3D { .mode =3D L2CAP_MODE_BASIC };
+ 	struct l2cap_conf_efs efs;
 =20
  	BT_DBG("chan %p, rsp %p, len %d, req %p", chan, rsp, len, data);
 =20

--Signature=_Tue__20_Dec_2011_13_02_31_+1100_74=Gb_Gk/nTJvZ4.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO7+y3AAoJEECxmPOUX5FEcSoQAJmavzbTzWSd3+KheF98Jj+6
qS72mwQHAYM3Qy1hUNV8GcGhwtFZoax3qdyhhZvpIkA3IXFsbhJKPChOPeqtumBe
5Mcz3k6PnXyHHUnrpGWO4ZW3HPYxy0llXiNs7jl3L5l8+zhQd8jyjXV424SFTrn4
/dnPh/O210cpg865enRqJYc7h+WOShyZGSa6h5iGITgXdRQb16YIblEvkIKUh9qt
1t27scwdBPHHP7eE8Hbjwj+18l7NTJoFjpxEb2lsQgB4YWeozeBoprN5qayRi/Cd
Fmbppi3jWoeXGfQKz74G7JOzHbWDkGDbXfatB4M0RaqT9+bQnbiSEWDLe5bDY/Xc
0cF2AA9BNbnZCFYkIjQBXPKA6p4SjtKy9yp4Uo1r/we+YPf0lO+j3p016s/GUB2+
k8UPXDtzw7mkYgQz0//Z35tEd09A1cLJ98MkLUsOMeZDHEmmiC8ueouYDH2H7Flb
LnHHkLvnxMjG7PmoZge9B5E9XQfKRXh7TlVhoO1jzSJpbqhT6POmoOUB6/cBXL9X
65QFd/ufp5v+wdJKpjZnn+P5RI+nzPDn/XsSVVfxztkGXLS/lINWRh6OtnkDRsuA
mMKUD0lnTigAoy2U9OnEK6dMbvG0tdOj2i5EZXDRGxZ/w72smquP54ky5DkJY084
6MESSrs8tAXOGY9Tj3VH
=TXoJ
-----END PGP SIGNATURE-----

--Signature=_Tue__20_Dec_2011_13_02_31_+1100_74=Gb_Gk/nTJvZ4.--

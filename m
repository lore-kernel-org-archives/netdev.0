From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 2 Feb 2015 13:40:53 +1100
Message-ID: <20150202134053.7870bc16@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/MSI./W=lXxXrDmZGRaqCqEb"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/MSI./W=lXxXrDmZGRaqCqEb
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
include/linux/if_vlan.h between commit d4bcef3fbe88 ("net: Fix
vlan_get_protocol for stacked vlan") from the net tree and commit
df8a39defad4 ("net: rename vlan_tx_* helpers since "tx" is misleading
there") from the net-next tree.

I fixed it up (the former removed the code modified by the latter) and
can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/MSI./W=lXxXrDmZGRaqCqEb
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUzuO6AAoJEMDTa8Ir7ZwVCrsP/0EpvnzW3Tjdk7+4VVT4aakw
2VG4obAj45y7i7u6GpxHKKxHcQvcXoWj4FUO6n2khs5loaRvk4pugaooEn+rUacy
3mFR74JT5yPt+aZRisLTqAlNgLe8otfXuQ8WzJ1/6Uj8oquOnKviPlI0ArfPwoVs
67tbW/qGZW584bDU26a1QaFPNDb8BDvr0lQlA1eOeyjEpWQkvC5a6b6agOk6bIkA
zlUVxJQFVwmCplC14CkZb5Vq+aG2TT8MN0kGLfhEMrK4Oaw/WexlpCMNUjmwGIoV
2L5f1vta32YVDP8qyd/11qjr2u1dHFOUer3E1/v0SXIYXkqIScETlbuk+zCndwt3
B4T9dBAgYdUTkDBKLXmAbTuUYiGeMZtnK6vqCI3N/MfTzGSz+9Jvs0tfYBkUp+Cr
Maw+CXVXqa31yy/jU5i8jTqbi3+WoiURdrpgNPQQbZC9mqje2olwzL0VacSeXR3e
sWC4K7G6N1OQy2VHFq/5Ix9wWIbBerc4G5K+2VYypWlALZDGlDWorFOVh7Cwrco6
M+obeaHe9enKzMBRsLb71hg4T9uEY7mCLVq1+q0IuVjOIAR5UMWbgp4IUEVwI3Gz
VEJ6lfIcpSev7Yk/cv1eOM9HOIFD65CD/+YSXwfXwOsrZAZpzSbHtTh0yu5MpZR9
GuFvXWVxHrkFnY+d2lJG
=010+
-----END PGP SIGNATURE-----

--Sig_/MSI./W=lXxXrDmZGRaqCqEb--

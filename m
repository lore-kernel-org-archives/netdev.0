From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Thu, 14 May 2015 17:39:32 +1000
Message-ID: <20150514173932.7ee4e662@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/I9uTaF77wgAX1/kGsE0_7Wc"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Scott Feldman <sfeldma@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/I9uTaF77wgAX1/kGsE0_7Wc
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
net/bridge/br_stp.c between commit 42275bd8fcb3 ("switchdev: don't use
anonymous union on switchdev attr/obj structs") from the net-next tree
and commit "net/bridge/br_stp.c: work around gcc-4.4.4 initializer bug"
from the akpm tree.

I fixed it up (the former solves the same problem as the latter but in
a different way, so I just dropped the latter) and can carry the fix as
necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/I9uTaF77wgAX1/kGsE0_7Wc
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVVFE0AAoJEMDTa8Ir7ZwVki4QAIuuxYqr/F/iZPPfKJwg+JGm
8sMeXc+Fz9ZU9sap1WJnuzhSdF8lELiR8wXxAKomjDpeX8SEn9UyfokwkEr/Zygb
Ts9Zuub+jNd0LuTGydDRJFSmmnzg93CmUjsvgAra+zQNzvC17vB5iGpGKqrKC7Ql
ssJp7FFu126tqChfi8D9hv1fEKlwF263k4DvX7J2bcqY2cpz69Bk7ymwUhpm8pnX
KzwBK6RWXtA0er4/08DQF+/zdTqIDlntEsdph9KHf2adRj1vcYcVzWejI371YhFX
CIUfIY434dyQ3ZylEDsL1lUl6okkSQGfR88uVKwbwUzIMX/3pCIacBkMI/472u7z
ww3b56yvcwpbK7zOYISgEi7ML796BtJe1RL96EDF+YMtE8orHwmU280cdnQ1UG/k
dJlO9C4rDtks4dBT67Jq3+Nr0DuQLggDFZ+pD6YLZVttgkp41mFQTvCmKEZQVKhE
cFpwbJsj4/EtAM2oVUI0a8zEEmpI7Qblq6ljS6TdTuwV2gucOdRCRJFqynD5sEFC
cOccRxHvEM4bplxnkC3pmXdpcrF/krHvt8RuKGr94r02E9warH4XkpB0+Htf92gI
drhSYGywma5ofh788H/UPKK1y8xnSzwIqLTsb7A5IA0zAe8iRNwrRNg8EDRmRAtv
QeZQCRu83t/GWivhW9SY
=5fiv
-----END PGP SIGNATURE-----

--Sig_/I9uTaF77wgAX1/kGsE0_7Wc--

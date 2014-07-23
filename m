From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net-next tree
Date: Wed, 23 Jul 2014 18:18:59 +1000
Message-ID: <20140723181859.09fd1d9f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/rYEkWlgdi_Y2HekNNcBIL+K"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/rYEkWlgdi_Y2HekNNcBIL+K
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
drivers/infiniband/hw/cxgb4/device.c between commit da388973d4a1
("iw_cxgb4: fix for 64-bit integer division") from the net-next tree
and commit "drivers/infiniband/hw/cxgb4/device.c: fix 32-bit builds"
from the akpm tree.

I fixed it up (the patches have the same intent, so I just kept the one
in the net-next tree) and can carry the fix as necessary (no action is
required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/rYEkWlgdi_Y2HekNNcBIL+K
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJTz2/4AAoJEMDTa8Ir7ZwVCH0QAJaSBpKespFwuI3HVPKFj9SY
9A38hJ2QeiAjpPohvSOtHhMp/+La1u8mv1liscaIesyNxYUxjEwBYKrzGcdJJzhM
TyJ0/wiZn7N9xVcgED1fUV6I+ijL3/Z3ljjH6aLY28UaeH/HjzqHIwVCCah/BudS
VAPAzxbX04J1WZ4jVKJFJzef2CVXpF4ufKrQmQxuduFF/v0lbX8gTqoM80mZAA9y
bkh6SCaKAGrthXoFGPV1siQ10c8apAqNmjt9Icg6HtaPygwVwkUgO/NsSbDKPqI+
j8XP03AL7YTtt9tUFkIwd/MDktnJIvKEqTt0YyCiEVFjTe0hoMM+uYoEgkgSp4dn
khM3twQUM4MPNGELTU278IxW8dcPXkMuHN6mnJeDnZW0khZGnXQaui7K9H0d+rEM
i28EDtGNorrUhV2uQzMAU5wEpocGy/miBrsXhJJyoulN7/o44PnJQRtWo9U40lXw
OMmusEwat6A8VVebrTiIhl3M5VwacUEJoJYCyo3W4AjNqcluHtOtrK/Vh9jHPOM9
IvN5xWhaNFjv6BLSd/q+/hj8+DT9qHAMQjNdNx6DjmriUesidwHnebeFozbz9Y7V
MyQIbao1XQgqgMUbUx8KsrmTcm2fRJ6TTEdyivkl6oGclKIk5yEKa8Zuvkr52996
dDRH989IU1tOBXHWgk1P
=OLUS
-----END PGP SIGNATURE-----

--Sig_/rYEkWlgdi_Y2HekNNcBIL+K--

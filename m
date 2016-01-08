From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: constify ixgbe_mbx_operations structure
Date: Fri, 08 Jan 2016 00:25:42 -0800
Message-ID: <1452241542.19358.30.camel@intel.com>
References: <1451804129-32213-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HujZiObMIwXNRgw4Hj1C"
Cc: kernel-janitors@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451804129-32213-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HujZiObMIwXNRgw4Hj1C
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-01-03 at 07:55 +0100, Julia Lawall wrote:
> This ixgbe_mbx_operations structure is never modified, so declare it
> as
> const.=C2=A0 The other structure of this type is already const.
>=20
> Done with the help of Coccinelle.
>=20
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
>=20
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c=C2=A0 |=C2=A0=C2=A0=C2=
=A0 2 +-
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h=C2=A0 |=C2=A0=C2=A0=C2=
=A0 2 +-
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |=C2=A0=C2=A0=C2=A0 2=
 +-
> =C2=A03 files changed, 3 insertions(+), 3 deletions(-)

Dropping this patch since Mark has provided a more in-depth patch to
fix the entire driver.
--=-HujZiObMIwXNRgw4Hj1C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWj3KGAAoJEOVv75VaS+3Ou5gP/0cUBuVDqfV+A1OaFgvwslBs
81Ybi2GBd2FydLRgQBDYNsExVAZfBzPkUwy4EDJebSeOSjqsi+PEpRkGkZ9gFd6r
xIf7JJQtd5cNScKbozfcX7ptnwT7NDAm+Tsx1rruws+RVEnFcrTpqUy/t4hyKA79
pYbh8NASmO3Apuzpv4rJ2vQgoZT3XOW7ZxTfRU8w74wvWX7QVhbThGMjJQOBKeAq
9mVaXvoyC62jtMFJ1c//sEzyh92SVhRtH4lSSbeIIsLPtCtKZvq3vQUtjse24XeY
TYQxbTiGd1w5aJOoueYvqCWOJKgQu2SEDf0tKhl4YnnPg3RR582vaFTH6hkEewDP
oHhaUrEtkTAUeWHezSJpUqcSEvzswhaoumeydB+FHMHfyer8IUTkedgFwTcyV3VT
odKZvGKSUq3qPRsQwV/2GQd0Wb5fS6IeajMc0KdXvWX/vloD8nthxTliw0iVHam5
45GhhbRoVP+oargbXfEBX3UVLUXcoX4s6d560L/h6HFHpin8KRX6YYuF4cd1SMFF
3QAkwtQN9GPwINJX7ngGPQKXSRGc7XylnXID2dSYz48tEiu+c8c5+FgbKMUdNGx1
ooFSPBTTvsAUZWoc6HOxKb7Kwo7UCfhOAqrzeghGYQmXKhItITr7gyaUnbB1CHSo
XX4U3h+dhpdXxV4rEOci
=KOlC
-----END PGP SIGNATURE-----

--=-HujZiObMIwXNRgw4Hj1C--

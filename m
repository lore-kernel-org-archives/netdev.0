From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 5 Jan 2015 14:36:15 +1100
Message-ID: <20150105143615.4e75d3fe@canb.auug.org.au>
References: <20150103091101.04b2c11e@canb.auug.org.au>
	<20150103.144530.1032237292364564169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/ei2ObrYV7OQ9xa9e0d85lX_"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, richardcochran@gmail.com,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150103.144530.1032237292364564169.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/ei2ObrYV7OQ9xa9e0d85lX_
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi David,

On Sat, 03 Jan 2015 14:45:30 -0500 (EST) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Sat, 3 Jan 2015 09:11:01 +1100
>=20
> > After merging the net-next tree, today's linux-next build (powerpc
> > ppc64_defconfig) failed like this:
> >=20
> > drivers/net/ethernet/mellanox/mlx4/en_clock.c: In function 'mlx4_en_ini=
t_timestamp':
> > drivers/net/ethernet/mellanox/mlx4/en_clock.c:249:2: error: implicit de=
claration of function 'CLOCKSOURCE_MASK' [-Werror=3Dimplicit-function-decla=
ration]
> >   mdev->cycles.mask =3D CLOCKSOURCE_MASK(48);
>=20
> Stephen please let me know if this failure is persisting.

All the ones I reported are fixed, thanks.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/ei2ObrYV7OQ9xa9e0d85lX_
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUqgazAAoJEMDTa8Ir7ZwVbiIP/jryimpbFieQYrwzluJW9VRj
A2zB2Lxe4zSPLwRtgx2TAuvPqoPma9SOR1e37SvE203jFy+Q9ZZkT/rq0nSO4y3s
I+9xaQtYq/HSiecTgomHTt9UHMy1wpcyBghNCOD1AbViLPjyIVO0956VUvKuq5R4
TpJI20GeXNcHilRryV0qTFu+lXMfjr79FCkrvgjPL6ykE2DPFhqEouEmwSZ6I8Ny
6N4S9geY+9jD9HeUtzdf57nkxYOfqhAemPjam78aysER2JDS6e3GjbXthOSnU2QA
KV+4Bovw/3x99mGqk2s2tC+iJ5LbgnfHtplK3X0S6hNPie+1Po0pKioCW8G58qhG
TL+keiQa6rLRmtPVbinSzLWCLCH/sEjLNIinFVl8tMbn0k8S7w2BeHXMw5YrnNwh
syxs8zaMAHyMCtDXkDRzwL5wYbUzWrtluoVEen2b8ZP1bF0AppL/2vSntPf43jP+
TL/wE8wMG+TkO6AQD7md9mxXseJaznrhzAAEW7JoJdmRrUsIfZq3wdiRXeFgjvYR
rbdCX37chpfOawTdDBODcZiwDdht83AhgwxOQz3oBD84j4H/TnBRQvsB+vNGKu+V
vaHDNT2KgqOIvzZ+nQgsMFxuUCYSzLIs1LdmkNVM5EF1svvZVr8qF+Kg+69swR/+
BFdIR2AOrMumL9lPtlP0
=xtMt
-----END PGP SIGNATURE-----

--Sig_/ei2ObrYV7OQ9xa9e0d85lX_--

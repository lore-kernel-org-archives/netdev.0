From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Fri, 22 Apr 2016 16:20:43 -0700
Message-ID: <1461367243.3018.42.camel@intel.com>
References: <20160413175028.5d3a4cf2@canb.auug.org.au>
	 <20160413.111513.295841881765244758.davem@davemloft.net>
	 <20160422092017.GY3217@sirena.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lHjQNpBqXycFjvz0Tr57"
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	mark.d.rustad@intel.com, andrewx.bowers@intel.com,
	kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org
To: Mark Brown <broonie@kernel.org>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160422092017.GY3217@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-lHjQNpBqXycFjvz0Tr57
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-04-22 at 10:20 +0100, Mark Brown wrote:
> On Wed, Apr 13, 2016 at 11:15:13AM -0400, David Miller wrote:
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
>=20
> > > After merging the net-next tree, today's linux-next build (arm
> > > allmodconfig) failed like thisi (this has actually been failing
> for a
> > > few days, now):
>=20
> > > ERROR: "__bad_udelay" [drivers/net/ethernet/intel/ixgbe/ixgbe.ko]
> undefined!
>=20
> > > Caused by commit
>=20
> > >=C2=A0=C2=A0 49425dfc7451 ("ixgbe: Add support for x550em_a 10G MAC ty=
pe")
>=20
> > > arm only allows udelay()s up to 2 milliseconds.=C2=A0 This commit
> > > adds a 5 ms udelay in ixgbe_acquire_swfw_sync_x550em_a() in
> > > drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c.
>=20
> > Jeff, please have your folks look into this.=C2=A0 Probably just a
> simple
> > conversion to mdelay().
>=20
> This is still present, it's been breaking ARM allmodconfig builds for
> about two weeks now.

Interesting that no one spoke up until just a week ago. =C2=A0I have a fix
and I ready to push it to David Miller.
--=-lHjQNpBqXycFjvz0Tr57
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXGrHMAAoJEOVv75VaS+3OLnwP/2bIB4v7GVm6EO1DRvAcFBIy
uNRAmRB+7vDX2Wl3AoaimDU7QJuVESFusiDn5hv4667q9YKbW4M17f5QiICqyZqO
Xxh+enmerP/sbRfiJxtrGFOGJmiWdPXqAV01ezaAMDb2YgQDJ7m2CxCWhzPc4W28
Zy9eEYGi2V/UlLDXgCYefHRw9lwM+PMa76hnF5Ume/PgKncfxl9a1Xfzx6e8glI0
5cI6LHPPT49DW0QRP8zy29AHJ/f0+PsA8sOjaDg8L+TtSNcbHl+BVEGcpN9jyYJN
zKpWwFOJrzXnUcp6rovzD3/xuughTbK55so3D1Hv68/s4Nba2za+PVQiTOkZnBex
TAuxXBNoYZcnxGi7Eqsxt3PL7HUR3iRqrfV7udoj/+IkJZ8RUssh2e3VX5n53nyq
pRC2m4P8P8v8k96ZwpK3TzQLYeNbxrt/m3kIXRw7FYzY11YS6Bv2U+xD5PPyXM27
qz/Uufy70EV6+MPa0nDX3cy955kOjN2hhpOzl6TaRcUgH35xNf3gBmSXvucwY0On
wek3WTCgNKOclpVGpKUdjHF6dBNj01WkqA7+fmy6XgL5yTDqiSRP2x4ZC3dkUr6y
tKw6FdL6oclbix5E8WAj12W2plwOCGkueS8lUu7X2G5LclUJJvQqli9BCGJ93ULo
X7hX8MITWWZNskl6K9oW
=x5pR
-----END PGP SIGNATURE-----

--=-lHjQNpBqXycFjvz0Tr57--

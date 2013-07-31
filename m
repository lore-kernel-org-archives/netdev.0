From: Felipe Balbi <balbi@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new
 CPSW IP version
Date: Wed, 31 Jul 2013 22:45:23 +0300
Message-ID: <20130731194523.GB900@radagast>
References: <1375272746-24446-1-git-send-email-mugunthanvnm@ti.com>
 <20130731144957.GC4904@netboy>
 <20130731152827.GB25618@radagast>
 <20130731163845.GB4234@netboy>
 <20130731184525.GA629@radagast>
 <20130731192229.GB8027@netboy>
 <20130731194332.GA900@radagast>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aM3YZ0Iwxop3KEKx"
Cc: Richard Cochran <richardcochran@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-omap@vger.kernel.org>
To: Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:36574 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752816Ab3GaTph (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 15:45:37 -0400
Content-Disposition: inline
In-Reply-To: <20130731194332.GA900@radagast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--aM3YZ0Iwxop3KEKx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Wed, Jul 31, 2013 at 10:43:32PM +0300, Felipe Balbi wrote:
> > > > > > > The new IP version has a minor changes and the offsets are sa=
me as the previous
> > > > > > > version, so instead of adding CPSW version number in the driv=
er, make the driver
> > > > > > > to fall through to the latest versions so that the new versio=
n of CPSW which has
> > > > > > > the same register offsets will work directly without patching=
 the driver.
> > > > > >=20
> > > > > > This doesn't make any sense to me. Why not just add the new ver=
sion
> > > > > > number?
> > > > > >=20
> > > > > > None of the hunks in your patch are on performance sensitive pa=
ths, so
> > > > > > I really can't see any point in removing the error checking.
> > > > >=20
> > > > > well, if a new revision of the IP comes, the driver at least has =
some
> > > > > chance to work without having to be modified. If it turns out tha=
t there
> > > > > are really different features, then we patch a new version, other=
wise we
> > > > > should just assume highest known version and try it out.
> > > >=20
> > > > And if the driver reads junk from some random address due to
> > > > bootloader/DT/multikernel madness, it will happily peek and poke
> > > > around instead of rejecting the wrong version number.
> > >=20
> > > that'd be a bug in the DT anyway, why should the driver have to cope
> > > with broken data ?
> >=20
> > Um, it is called error checking?

one more thing, why do you consider a new revision to be an error ?

--=20
balbi

--aM3YZ0Iwxop3KEKx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJR+WlTAAoJEIaOsuA1yqREe2wP/067hpt7g0f40XG550GdnW8q
Sq9MuhsuvkF5HN6n/VndvvVf4Yr8ZayulWnW/wXJDBpGBvMSgKRunTRUVstmyHbe
i3Y8Y0Au5xhbToKIRtrPdY2uXXFoS+wVqhlDSHke9+f+2N6de2ohpOXJUp2aQBQd
HRt1HwapYQDAzDn0SuFjitBLNmQ9LetdKOJ4oSJMICEVjjZ8xsAzLLnG5TxcI7a6
U9kU8hE1kp+aO03DyuM2hOp7l+C17rdSrR0Pl5fe97ti2wGMxW8WFBf8mF5MJQ0u
Uj/gJmSurqAKw0B5u3Z815sk+ZF/PE3c4ohr4ZRvI5lNyIW9uq6oFFQ5UVojY+UJ
AnLsman3CuegFgR6lgDwv7lWWPSIVk0xv8E1XOhn2rHj2tcPT0vxp3A3E37QMYNi
4yTuoDOTmjF5HAzlfnA9cp0MsCuAypTKJ9oeHiWQir3Uw41F6gTYAZvwaGmPHTX8
wFXXZvT7najRcoTLXfmN6s6obQiUfYQyE12Oo8X5wbPv5vX9L0A2Yx3Y1/Qc32xV
e9/Rrc6n6qjtlgQ8uwXzUKI7Gz92SEfeFW3BpSozvoJKg0empGUp81B92dJdPDQr
Rf9o35LHnrtNcjmqTqbvx/gJn4Ya/afbbpn1c7gxVnHsR6VpGp4t67zYe2jIHFMd
Qb7Z7Jy035wxFqvtuQBu
=S+ki
-----END PGP SIGNATURE-----

--aM3YZ0Iwxop3KEKx--

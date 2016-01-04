From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20160104 build: 3 failures 15 warnings (next-20160104)
Date: Mon, 4 Jan 2016 22:44:05 +0000
Message-ID: <20160104224405.GV16023@sirena.org.uk>
References: <E1aG3zo-0000gt-2t@optimist>
 <20160104165025.GN16023@sirena.org.uk>
 <3705737.6TGxRxdFzW@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="grb+5QKeMfpTKipq"
Cc: kernel-build-reports@lists.linaro.org,
	Igal Liberman <igal.liberman@freescale.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3705737.6TGxRxdFzW@wuerfel>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--grb+5QKeMfpTKipq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 04, 2016 at 11:07:41PM +0100, Arnd Bergmann wrote:
> On Monday 04 January 2016 16:50:25 Mark Brown wrote:
> > On Mon, Jan 04, 2016 at 12:12:20PM +0000, Build bot for Mark Brown wrote:

> > and various other linker errors caused by the fact that the new fman
> > driver uses PHYLIB but does not depend on or select it.

> This is the patch I submitted for the problem. I don't think that simply
> adding the 'select' would be a good idea because that would force PHYLIB
> builtin for allmodconfig.

Indeed, that was why I held off on my own patch - I wanted to go back
and try to understand why we were using a bool there.

--grb+5QKeMfpTKipq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWivW0AAoJECTWi3JdVIfQuosH/AiKJk6TyPcfyzucCTefco2i
DSg5q2wRsHbO6wzIyK/uBMQ7UEjNQL9g2oZEAjWRUEWCBtlkYvt1P6iq1Gjl5S9y
BsgWj6LS5eUg+8dxev7jINTXBqytJ3AF37cdDXalRE363/12QDuYbySVqeqE3dAR
IKBDZXmYZMAQIEaJERC/K7UAizRPAEByORLxJQRnv3hpxAXZKX9ec4VwXLeSrWPx
rYctfHibTHaz9uCf2EjgjV81OzCvHewvI4bzjyPmTKbo+ZDcG9dpsQPXiBHTKbYD
mD1zGERoqdFtmHhEoxd5RtMGud7JhF5K1jkMOgd02HvvVB1/tdnaizbYiGdlyeo=
=yYZb
-----END PGP SIGNATURE-----

--grb+5QKeMfpTKipq--

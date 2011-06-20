From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: RE: [RFC] Moving files around in drivers/net
Date: Sun, 19 Jun 2011 18:48:52 -0700
Message-ID: <1308534533.22851.19.camel@jtkirshe-mobl>
References: <1306956602.32125.28.camel@Joe-Laptop>
	 <1306957998.3076.18.camel@jtkirshe-MOBL1>
	 <1306958478.32125.32.camel@Joe-Laptop>
	 <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	 <1308186619.12377.23.camel@Joe-Laptop>
	 <3367B80B08154D42A3B2BC708B5D41F63F1859422D@EXMAIL.ad.emulex.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-ees5D+dxl62LDex0AUvg"
Cc: "joe@perches.com" <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"jengelh@medozas.de" <jengelh@medozas.de>
To: "Sathya.Perla@Emulex.Com" <Sathya.Perla@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23925 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878Ab1FTBtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 21:49:11 -0400
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F63F1859422D@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ees5D+dxl62LDex0AUvg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-06-15 at 22:05 -0700, Sathya.Perla@Emulex.Com wrote:
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]=
 On
> >Behalf Of Joe Perches
> >Sent: Thursday, June 16, 2011 6:40 AM
> >To: Jeff Kirsher
> >Cc: netdev; David Miller; Paul Gortmaker; Jan Engelhardt
> >Subject: Re: [RFC] Moving files around in drivers/net
> >
> >
> >commit 931da59411e60574a1235d0ad2d63ebd1638a859
> >Author: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >Date:   Fri May 13 00:37:27 2011 -0700
> >
> >    be2net: Move the BladeEngine 2 driver
> >
> >    Moves the Server Engine driver into drivers/net/ethernet/benet/ and
> >    make the necessary Kconfig and Makefile changes.
> >
> >    CC: Sathya Perla <sathya.perla@emulex.com>
> >    CC: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> >    CC: Ajit Khaparde <ajit.khaparde@emulex.com>
> >    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >
> > MAINTAINERS                                   |    2 +-
> > drivers/net/Kconfig                           |    2 --
> > drivers/net/Makefile                          |    1 -
> > drivers/net/ethernet/Kconfig                  |    1 +
> > drivers/net/ethernet/Makefile                 |    1 +
> > drivers/net/{ =3D> ethernet}/benet/Kconfig      |    0
> > drivers/net/{ =3D> ethernet}/benet/Makefile     |    0
> > drivers/net/{ =3D> ethernet}/benet/be.h         |    0
> > drivers/net/{ =3D> ethernet}/benet/be_cmds.c    |    0
> > drivers/net/{ =3D> ethernet}/benet/be_cmds.h    |    0
> > drivers/net/{ =3D> ethernet}/benet/be_ethtool.c |    0
> > drivers/net/{ =3D> ethernet}/benet/be_hw.h      |    0
> > drivers/net/{ =3D> ethernet}/benet/be_main.c    |    0
> > 13 files changed, 3 insertions(+), 4 deletions(-)
> >
>=20
> If you are going to consistently have the path as drivers/net/ethernet/<c=
ompany-name>/<driver-name>, then
> be2net driver must be under drivers/net/ethernet/emulex/be2net/
>=20
> thanks,
> -Sathya

That sound fine.  I was not consistent about using
driver/net/ethernet/<company name>/ because companies have been
bought/sold and a driver may change hands one or more times.  So I tried
to avoid using company names unless I was confident about it.

I will make the requested change.

--=-ees5D+dxl62LDex0AUvg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJN/qcEAAoJECTsCADr/EWUNmoH/1cR5qgYD/UHXBdaB8uxvtUy
8m2GBLhAtSeUa3wYZHOPeWWLP9wcYnIjPJw56CZXxYmnnsj+hihL+pGJks/N3Nng
pLIK/8tsFS5naFVjNgMu9hGgfUpzAVhKiqmV7XR25AGLLF4pQQiGZ9J9GYsDzQro
cvdSieshI6NIzSMiJpovziqjOSTq+1vYrpW7/iN+gNhEd+rqVJ+46WTbjv7Uql+X
cf9F5QTfsgtNis+ISTWKxE5AJJjktsxC2GWtb5i2bQlQBb1q5IZDNwIWASqs1q5I
d/or4eLG4Ed9sGp/xH1qZbCxXVeQmzFnKKz2DCZhsGnoLnJhXPYqPXtva/0eAl8=
=DXO/
-----END PGP SIGNATURE-----

--=-ees5D+dxl62LDex0AUvg--


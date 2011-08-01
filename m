From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 02/71] 3c*/acenic/typhoon: Move 3Com Ethernet
 drivers
Date: Mon, 01 Aug 2011 13:15:56 -0700
Message-ID: <1312229757.1984.6.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-3-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110801100303.48ed75f7@bob.linux.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-eELgCz3ELM8TRUpISd+4"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Philip Blundell <philb@gnu.org>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	Donald Becker <becker@scyld.com>,
	Craig Southeren <craigs@ineluki.apana.org.au>,
	David Hinds <dahinds@users.sourceforge.net>
To: Alan Cox <alan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:17861 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821Ab1HAUQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2011 16:16:00 -0400
In-Reply-To: <20110801100303.48ed75f7@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-eELgCz3ELM8TRUpISd+4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-08-01 at 02:03 -0700, Alan Cox wrote:
> On Sat, 30 Jul 2011 20:26:21 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
>=20
> > Moves the 3Com drivers into drivers/net/ethernet/3com/ and the
> > necessary Kconfig and Makefile changes.
>=20
> This still seems crazy
>=20
> The 3c503 is not being moved (as its 8390 based)
>=20
> But the 3c505/3c523/3c527/3c507 by that logic also shouldn't be moved
> as really they all belong with the rest of the Intel devices they are
> basically variants of (the 3c527 is weirder, in fact you can probably
> run CP/M 86 on it if you were mad enough)

I did as you asked, just not in this patch.  I should have cleaned up
this patch to reflect the changes I made in patch #4 and #10.

>=20
> >  drivers/net/{pcmcia =3D> ethernet/3com}/3c574_cs.c |    0
> >  drivers/net/{pcmcia =3D> ethernet/3com}/3c589_cs.c |    0
>=20
> These are currently sensibly where they belong - with the pcmcia
> adapters.
>=20
> >  drivers/net/{ =3D> ethernet/3com}/3c59x.c          |    0
> >  drivers/net/ethernet/3com/Kconfig                |  200
> > ++++++++++++++++++++++
> > drivers/net/ethernet/3com/Makefile               |   16 ++
> > drivers/net/{ =3D> ethernet/3com}/acenic.c         |    0
> > drivers/net/{ =3D> ethernet/3com}/acenic.h         |    0
>=20
> And most Acenic devices are probably branded Netgear not 3COM and may
> also claim to be from Farallon, SGI, Alteon or DEC. Again not a 3Com
> originated part.
>=20
> So I still think this patch is utter nonsense and just noise.
>=20
> There isn't any sense in trying to line the network drivers up by
> whatever is written on the box that was thrown away years before. The
> reality is that most cards do not bear anything relevant to the chipset
> vendors name, even by the early 1990s.=20
>=20
> Architectually it makes more sense to keep tidy by bus type and by
> chipset, not by vendor name
>=20
> NAK
>=20
> And even if you wanted to make Kconfig simpler - you don't need to move
> files around.
>=20
> Alan



--=-eELgCz3ELM8TRUpISd+4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJONwl8AAoJECTsCADr/EWU8RAH/Rz/5BmzdK0kU7H2c6rZLK6s
LuwTNbmxWu34nNMAd4iy4HFqTO18SpuSo23ArRt7ho4wPmUeWHM6ybzmR6n7gMnR
yK1hU4GyJbT+egWe0wuXvz21vjqCedRp+YLbjxXksqhLSfp3gbs0b3kfay1Avk+d
PIPHhQZgGXpIvAMs9JBJnXtXVJq6WjlTZnusKDPpbhXxmTERHSnXIbB8onFz0HLA
TBT8ImaNpOJnFqATT+8VNEmMGgwn2EQzOFzoTSJ5zF21YA2DEM7EwFh5AQzlsEvh
yNeSHgnd1oh+VA8h+m00c0dWTDIeyV4DoLqYj2gWh5vhqpiPMPokkdOL961pmYk=
=8Wn2
-----END PGP SIGNATURE-----

--=-eELgCz3ELM8TRUpISd+4--


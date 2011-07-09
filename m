From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 46/72] ixp2000: Move the Radisys driver
Date: Sat, 09 Jul 2011 08:58:56 -0700
Message-ID: <1310227137.26989.43.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-47-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110626114721.GA19500@wantstofly.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-H7ZL6I49djnerNAZzcat"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Lennert Buytenhek <kernel@wantstofly.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45577 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971Ab1GIP7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 11:59:02 -0400
In-Reply-To: <20110626114721.GA19500@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-H7ZL6I49djnerNAZzcat
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-06-26 at 04:47 -0700, Lennert Buytenhek wrote:
> On Sat, Jun 25, 2011 at 06:58:57AM -0700, Jeff Kirsher wrote:
>=20
> > Move the Radisys driver into drivers/net/ethernet/radisys/ and
> > make the necessary Kconfig and Makefile changes
> >=20
> > CC: Lennert Buytenhek <kernel@wantstofly.org>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  MAINTAINERS                                        |    2 +-
> >  drivers/net/Kconfig                                |    2 --
> >  drivers/net/Makefile                               |    1 -
> >  drivers/net/ethernet/Kconfig                       |    1 +
> >  drivers/net/ethernet/Makefile                      |    1 +
> >  drivers/net/ethernet/radisys/Kconfig               |   16 ++++++++++++=
++++
> >  drivers/net/ethernet/radisys/Makefile              |    5 +++++
> >  drivers/net/{ =3D> ethernet/radisys}/ixp2000/Kconfig |    2 +-
> >  .../net/{ =3D> ethernet/radisys}/ixp2000/Makefile    |    0
>=20
> The ixp2000 is a series of Intel ARM SoCs, and the ENP2611 is a Radisys
> PCI board based on the ixp2000 series (ixp2400), so it doesn't make
> sense to put everything in the radisys/ directory.

It was suggested earlier that it probably should be in either ixp/ or
radisys/, and someone suggested that ixp/ might be confusing.  If you
would like to keep it under drivers/net/ethernet/ixp2000, I am fine with
that as well.

>=20
> If you insist on moving all drivers into vendor directories (I don't
> like that idea at all -- are we going to rename directories and shuffle
> stuff around every time vendor A buys vendor B or takes over one of
> vendor B's products?), at least the core ixp2000 code should be under
> intel/.

It was not my preference to place drivers into vendor specific
directories because of that very reason, as I did the work, it just
tended to work out that way.

The reason (as stated before) that it was not moved into intel/
directory is because the driver was not written (and supported) by
Intel.

--=-H7ZL6I49djnerNAZzcat
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOGHrAAAoJECTsCADr/EWU3pwH/3q/5+hr0VwUrPNtWf8QGqNG
pIa39zh5lvHsUuHB7OPGnE3bSZDE4LxH4T0A38SkTvczhSvfJQ8Imms8ebe5DOTg
d9fNbqO9jzFshQG3RNo9Tsh66KrZ6vYAVblD1ybhsMSDBfZxgp637URq04ESBVKV
K8HRdrp1roxj1sHHKv1V76Fn9UwF9Vc+K5oSUYKEYAWIvX/jxZUeJLIBLJVHnINR
vsmK3Hz9nwVXO3o1oSu17fZsP2uh4nnvBtqsVpbz3lujwS8dDbqroazbrq9ccDXS
n3mENj2RY2tLXEmAQ6Cmn/5BJh2NX+v3EWlpHBQL7lfrdfmj6t28XtfEORLnBxU=
=M7E+
-----END PGP SIGNATURE-----

--=-H7ZL6I49djnerNAZzcat--


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 46/72] ixp2000: Move the Radisys driver
Date: Thu, 14 Jul 2011 18:19:17 -0700
Message-ID: <1310692758.2628.30.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-47-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110626114721.GA19500@wantstofly.org>
	 <1310227137.26989.43.camel@jtkirshe-mobl>
	 <20110715000819.GK951@wantstofly.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-dC083bFPj80eB4GrEkfX"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4835 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217Ab1GOBTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 21:19:19 -0400
In-Reply-To: <20110715000819.GK951@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dC083bFPj80eB4GrEkfX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-07-14 at 17:08 -0700, Lennert Buytenhek wrote:
> On Sat, Jul 09, 2011 at 08:58:56AM -0700, Jeff Kirsher wrote:
>=20
> > > > Move the Radisys driver into drivers/net/ethernet/radisys/ and
> > > > make the necessary Kconfig and Makefile changes
> > > >=20
> > > > CC: Lennert Buytenhek <kernel@wantstofly.org>
> > > > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > > > ---
> > > >  MAINTAINERS                                        |    2 +-
> > > >  drivers/net/Kconfig                                |    2 --
> > > >  drivers/net/Makefile                               |    1 -
> > > >  drivers/net/ethernet/Kconfig                       |    1 +
> > > >  drivers/net/ethernet/Makefile                      |    1 +
> > > >  drivers/net/ethernet/radisys/Kconfig               |   16 ++++++++=
++++++++
> > > >  drivers/net/ethernet/radisys/Makefile              |    5 +++++
> > > >  drivers/net/{ =3D> ethernet/radisys}/ixp2000/Kconfig |    2 +-
> > > >  .../net/{ =3D> ethernet/radisys}/ixp2000/Makefile    |    0
> > >=20
> > > The ixp2000 is a series of Intel ARM SoCs, and the ENP2611 is a Radis=
ys
> > > PCI board based on the ixp2000 series (ixp2400), so it doesn't make
> > > sense to put everything in the radisys/ directory.
> >=20
> > It was suggested earlier that it probably should be in either ixp/ or
> > radisys/, and someone suggested that ixp/ might be confusing.  If you
> > would like to keep it under drivers/net/ethernet/ixp2000, I am fine wit=
h
> > that as well.
> >=20
> > > If you insist on moving all drivers into vendor directories (I don't
> > > like that idea at all -- are we going to rename directories and shuff=
le
> > > stuff around every time vendor A buys vendor B or takes over one of
> > > vendor B's products?), at least the core ixp2000 code should be under
> > > intel/.
> >=20
> > It was not my preference to place drivers into vendor specific
> > directories because of that very reason, as I did the work, it just
> > tended to work out that way.
> >=20
> > The reason (as stated before) that it was not moved into intel/
> > directory is because the driver was not written (and supported) by
> > Intel.
>=20
> I didn't follow the discussion, but that seems like a silly argument.
> Does that mean that any non-vendor supported driver can't go into
> drivers/net/$vendor/?  What if the vendor starts contributing to the
> driver later on, will the driver be moved then?
>=20
> It seems that what you're saying is that you don't want the ixp2000
> driver in "your" subdirectory.

It is more that all the drivers that in intel/ are all very similar and
have "common" code which potentially code be shared.  We have been
looking at what possibilities there are for the common code between the
Intel supported drivers.  So it really did not make sense to throw a
driver into the intel/ directory just because it used an Intel chip, but
has nothing in common with the other drivers in that directory.  Sorry
if my previous explanation sounded like it I just did not want the
drivers in the intel/ because we did not write or support it.

After looking at ixp2000/ixp4xx drivers and the 82586/82596 drivers a
bit more, I came up with the solution of putting the IXP drivers in
xscale/ and the 82586/82596 drivers in i825xx/ directory.

--=-dC083bFPj80eB4GrEkfX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOH5WVAAoJECTsCADr/EWUmkUH/RFvIzwehucIzB1/68XWaq1a
NZzV/8xRtQ9XhG+jRqWyI2Sdyu8RbWMdgF9j1ODognVlNUbT1WCOJ9r3oo+Pzmdj
s2zC53T00xhrCg2BEzqgntpa516GMwKHlA66Fkmq46vk9tSCa4KHT1nm9JxctwvS
UUS6iKkbR5QwSCyqjh04aCxRF83ZvxzKFDX7794Bw7v6Eqj5BrihPrf5e+zyzSY9
9p47x9Xn6P63LBu7+ZYJanHLhpviffCJxkIcPgxMSFy2KvbcGHT04oznGSgYJBFO
cFx8fDZdEJZK9cVCN9z+jH/Lx+1UgWQxdkjMjzw6Kqk5jh9AMNn2lLqQzeCeovw=
=A2Yg
-----END PGP SIGNATURE-----

--=-dC083bFPj80eB4GrEkfX--


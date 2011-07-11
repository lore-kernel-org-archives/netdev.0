From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Mon, 11 Jul 2011 02:39:57 -0700
Message-ID: <1310377198.26989.90.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
	 <BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
	 <1310221836.26989.11.camel@jtkirshe-mobl>
	 <CAMuHMdVHRNk4arc75QKrzDmHYE+86NixPk6v9uGwOAPkUTCgJw@mail.gmail.com>
	 <1310345295.26989.76.camel@jtkirshe-mobl>
	 <CAMuHMdXfpbbfv7oT+0oDWJd0=x0BBqEeCcGWaxMHagTXoeCscQ@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-2DJg1Ci4hpzbYSLB0bQo"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52882 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972Ab1GKJj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 05:39:59 -0400
In-Reply-To: <CAMuHMdXfpbbfv7oT+0oDWJd0=x0BBqEeCcGWaxMHagTXoeCscQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2DJg1Ci4hpzbYSLB0bQo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-07-10 at 23:33 -0700, Geert Uytterhoeven wrote:
> On Mon, Jul 11, 2011 at 02:48, Jeff Kirsher <jeffrey.t.kirsher@intel.com>=
 wrote:
> > On Sun, 2011-07-10 at 12:34 -0700, Geert Uytterhoeven wrote:
> >> On Sat, Jul 9, 2011 at 16:30, Jeff Kirsher
> >> <jeffrey.t.kirsher@intel.com> wrote:
> >> > On Tue, 2011-06-28 at 13:33 -0700, Geert Uytterhoeven wrote:
> >> >> And (in some other patch) 82596.c is an Intel driver, not a
> >> Motorola driver.
> >> >
> >> > 82596.c is not an Intel driver, it is an Intel part.  The driver was
> >>
> >> Sorry, I meant "driver for an Intel part".
> >>
> >> > written and support by someone other than Intel.  I am looking at
> >> how to
> >>
> >> Sure. But I'm strongly against classifying drivers based on who wrote
> >> them ;-)
> >
> > I agree to some extent, because if that were the case, we would have a
> > donald_becker/ directory for several of the drivers. :)
> >
> > Here is one of the problem's I keep running into and there is no simple
> > answer.  While most of the drivers can be grouped together by the
> > hardware they use, that does not work "logically" for every driver.
> >
> > In addition, if vendor 'A' makes a part and vendor 'B' uses same part i=
n
> > a device/system/NIC and vendor 'B' creates the driver, supports the
> > driver and maintains the driver.  Should the part be categorized under
> > vendor 'A'?  IMHO, I think it should be categorized as a vendor 'B'
> > driver.
>=20
> Several of the Ethernet drivers are of a third type: vendor A chip, vendo=
r B
> card, entity C software.
>=20
> > I started this work with the idea of trying to organize the drivers in
> > the same way that the drivers were to be in the Kconfig, which tended t=
o
> > be drivers/net/ethernet/<manufacturer>.
> >
> > One of the problems that arise in this organization is what do we do
> > when vendor A is bought by vendor B, and vendor B takes on the support
> > of all the old vendor A parts/drivers?
>=20
> We don't care. We don't sort drivers by who support them. Eventually, ven=
dors
> lose interest and they all end up under "Linux kernel community" anyway.

It may just be me, these statements seem negative and bitter and is not
helping us "solve" the issue.  While the statements may be true,  I
would like to try and find a solution, what ever it may be, to better
organize drivers/net/ethernet/ drivers to help with maintenance and
future development.

>=20
> > So I am open to suggestions.  The process I have using to organize the
> > drivers has been to group drivers that use common libraries and/or code
> > first, then group by either manufacturer, maintainer, or common
> > platform.
> >
> > I would like to keep the lasi_82506.c, sni_82596.c, 82506.c and similar
> > drivers out of the intel/ directory because we would not be supporting
> > the drivers and they are not similar to our drivers that we do support
> > that would be in the intel/ directory.
> >
> > Again, I open to suggestions on how to best organize these types of
> > drivers.  Maybe create a misc/ or <bus_type>/ for these types of
> > drivers?
>=20
> "Similar" drivers should be together and consolidated (if someone has tim=
e
> to do it). They can even be of different brands.
> I.e. not all Tulip-compatibles were manufactured by Digital or Intel.

I agree and understand, that is why I am taking the time to do it.  The
drivers/net/ethernet/8390/, drivers/net/ethernet/tulip and
drivers/net/ethernet/sun/ are some examples of this.

>=20
> >> > better organize the 82596.c, lasi_82596.c, lib82596.c, and
> >> sni_82596.c
> >> > which all use an Intel Ethernet chip but were written and supported
> >> by
> >> > someone other than Intel.
>=20
> Gr{oetje,eeting}s,
>=20
>                         Geert
>=20
> --
> Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m6=
8k.org
>=20
> In personal conversations with technical people, I call myself a hacker. =
But
> when I'm talking to journalists I just say "programmer" or something like=
 that.
>                                 -- Linus Torvalds



--=-2DJg1Ci4hpzbYSLB0bQo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOGsTtAAoJECTsCADr/EWUuN8H/j1K+qUtqUlO3FZJ3F4UKcNB
4ArHNedn/Nsv7PVaoaPpTDKm7LSKpvr39aiFpsNk+5kGcLIWbKbKm9AkHAWpS4vu
XxlLfD8V23kZoQk1+fYQojvhHrqE6dX3bW2RXGFeLRW13Hi9ycKqoG0RDzI+Bbxr
CV5pIN2P4smWajviZtAmhrB0/9/V+63AabHM5hxXt1YGyKSGB8zpnOVP8AAsGD5j
QtceEV+04SEeaEVw6OOpM9OUBv8jOlsFv3xZqmmnaPFNOsbvJ7eDKyBKg6/8ROER
kxcJnXl10x+yI2znho1xdWlUY4Pl1+aPglO1OzLX85OFuHFOm+DOAY2I9Gz8lM0=
=6ujA
-----END PGP SIGNATURE-----

--=-2DJg1Ci4hpzbYSLB0bQo--


From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Sun, 10 Jul 2011 17:48:14 -0700
Message-ID: <1310345295.26989.76.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
	 <BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
	 <1310221836.26989.11.camel@jtkirshe-mobl>
	 <CAMuHMdVHRNk4arc75QKrzDmHYE+86NixPk6v9uGwOAPkUTCgJw@mail.gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-qArz0I8aAPFpgJ0Un49O"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43346 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756914Ab1GKAsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:48:16 -0400
In-Reply-To: <CAMuHMdVHRNk4arc75QKrzDmHYE+86NixPk6v9uGwOAPkUTCgJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qArz0I8aAPFpgJ0Un49O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-07-10 at 12:34 -0700, Geert Uytterhoeven wrote:
> On Sat, Jul 9, 2011 at 16:30, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > On Tue, 2011-06-28 at 13:33 -0700, Geert Uytterhoeven wrote:
> >> And (in some other patch) 82596.c is an Intel driver, not a
> Motorola driver.
> >
> > 82596.c is not an Intel driver, it is an Intel part.  The driver was
>=20
> Sorry, I meant "driver for an Intel part".
>=20
> > written and support by someone other than Intel.  I am looking at
> how to
>=20
> Sure. But I'm strongly against classifying drivers based on who wrote
> them ;-)

I agree to some extent, because if that were the case, we would have a
donald_becker/ directory for several of the drivers. :)

Here is one of the problem's I keep running into and there is no simple
answer.  While most of the drivers can be grouped together by the
hardware they use, that does not work "logically" for every driver.

In addition, if vendor 'A' makes a part and vendor 'B' uses same part in
a device/system/NIC and vendor 'B' creates the driver, supports the
driver and maintains the driver.  Should the part be categorized under
vendor 'A'?  IMHO, I think it should be categorized as a vendor 'B'
driver.

I started this work with the idea of trying to organize the drivers in
the same way that the drivers were to be in the Kconfig, which tended to
be drivers/net/ethernet/<manufacturer>.

One of the problems that arise in this organization is what do we do
when vendor A is bought by vendor B, and vendor B takes on the support
of all the old vendor A parts/drivers?

So I am open to suggestions.  The process I have using to organize the
drivers has been to group drivers that use common libraries and/or code
first, then group by either manufacturer, maintainer, or common
platform.

I would like to keep the lasi_82506.c, sni_82596.c, 82506.c and similar
drivers out of the intel/ directory because we would not be supporting
the drivers and they are not similar to our drivers that we do support
that would be in the intel/ directory.

Again, I open to suggestions on how to best organize these types of
drivers.  Maybe create a misc/ or <bus_type>/ for these types of
drivers?=20

>=20
> > better organize the 82596.c, lasi_82596.c, lib82596.c, and
> sni_82596.c
> > which all use an Intel Ethernet chip but were written and supported
> by
> > someone other than Intel.=20

--=-qArz0I8aAPFpgJ0Un49O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOGkhOAAoJECTsCADr/EWUNfYH/iJKHE/Z6hoKiMTD0QdnnmNg
9Z3zxddTKRcZUEVpQrlU45rZpwy+F5utBNgu+htSqSXCQ6MVC936d2DEMnDVhvi1
nlPSz/jEUWfj/g2hnoyRt8S6HllZOxaPROcqkQiJVUQnDrPSbCRtGpglKpHfA9yD
XnF7Yl4JrNOxCra9+/r8Q8UKv9MsRAThVv8qkXWvCyXtuN9szCm+s/XoUaGTgGRv
tmbjjtzgF2Wg0THjEMRnv30C2HmuzVj+7rl2Gf9WJNgPAKFWRWJmke1LZWyl4v9P
gipeAXoWV3mro2SPFYq8S5ocDCBZRhl0sitLBJg+rQASllFiXSe4k6Xs0wAuIsw=
=QC/a
-----END PGP SIGNATURE-----

--=-qArz0I8aAPFpgJ0Un49O--


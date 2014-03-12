From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303 3-port
 switch
Date: Wed, 12 Mar 2014 20:21:11 +0000
Message-ID: <1394655671.20857.2.camel@deadeye.wl.decadent.org.uk>
References: <531057A4.5020607@denx.de>
	 <20140228.130020.2022765291621434648.davem@davemloft.net>
	 <CAGm1_ksPrSjV8+o7LCGDtJz_6qY8bqGuqdpYNHKh_6JO2X0sqg@mail.gmail.com>
	 <20140311.163924.934541574802061078.davem@davemloft.net>
	 <CAGm1_kvTRkCq93BaPgN-MY5Oji3e4is7eq-BtOLv-LJGDCDqPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZKDonz5Hhd5i7+cubah6"
Cc: David Miller <davem@davemloft.net>, Stefan Roese <sr@denx.de>,
	netdev <netdev@vger.kernel.org>, "r.meier" <r.meier@siemens.com>,
	"lukas.stockmann" <lukas.stockmann@siemens.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34283 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752582AbaCLUVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:21:30 -0400
In-Reply-To: <CAGm1_kvTRkCq93BaPgN-MY5Oji3e4is7eq-BtOLv-LJGDCDqPQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZKDonz5Hhd5i7+cubah6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-12 at 09:43 +0100, Yegor Yefremov wrote:
> On Tue, Mar 11, 2014 at 9:39 PM, David Miller <davem@davemloft.net> wrote=
:
> > From: Yegor Yefremov <yegorslists@googlemail.com>
> > Date: Tue, 11 Mar 2014 21:11:16 +0100
> >
> >> On Fri, Feb 28, 2014 at 7:00 PM, David Miller <davem@davemloft.net> wr=
ote:
> >>> From: Stefan Roese <sr@denx.de>
> >>> Date: Fri, 28 Feb 2014 10:32:20 +0100
> >>>
> >>>> On 27.02.2014 23:02, David Miller wrote:
> >>>>> From: Stefan Roese <sr@denx.de>
> >>>>> Date: Thu, 27 Feb 2014 10:07:52 +0100
> >>>>>
> >>>>> Better is to come up with a real, types, interface for programming
> >>>>> such devices and providing an implementation of that.
> >>>>
> >>>> Right. Such a thing would be better. But as Florian already pointed
> >>>> out, nothing like this is available in kernel.org right now. Thats t=
he
> >>>> reason why I chose to implement this "simple" driver, btw as done in
> >>>> drivers/net/phy/spi_ks8995.c.
> >>>
> >>> When a suitable user facing interface is lacking, you create one
> >>> and submit it for review here.  You don't just submit adhoc driver
> >>> local stuff.
> >>
> >> David, what about enabling ethtool to read/write from/to the PHY
> >> registers (via passing PHY ID and register number)? I'm trying to get
> >> ICplus IP175D running and it has lots of registers, that I would like
> >> to look at dynamically.
> >
> > For debugging, register dumps are already supported by ethtool.
>=20
> Do you mean 'ethtool -e' option? AFAIK it dumps Ethernet controller
> regs, if it implements ethtool_ops.get_regs(). What I need are PHY
> registers, that I can get via MII interface. ethtool should provide
> access to PHY registers like mdiobus_read() and mdiobus_write()
> routines.
[...]

Perhaps, but only as a test/debug interface.  It is not acceptable as a
production configuration interface - that needs some abstraction so the
same command will work on any switch chip that can support the
operation.

Ben.

--=20
Ben Hutchings
Any sufficiently advanced bug is indistinguishable from a feature.

--=-ZKDonz5Hhd5i7+cubah6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyDBt+e/yOyVhhEJAQo+3Q/9FiKJ3g5aWYu/zHISX9wwDJ3dRfJXfmvD
Gq/nKyzO7NyG+fvxOWw5asAkKr0ezO5NpPYotgebKBjqtn7jJe6hoSx46RkEurin
TObMceRGHG5JhCAhyFSh1JXlYzmKtwMaDolRiwLG3RZP/chwNJeT8grKNMZAIj+j
2KCvYrMRwbhmVEKUsDgz5s0hZc/Tyic/pPJ/7sLqbFD/1BHRxEyt04nEUG041TK4
lZ+vF8mElYBnhU2VXKwfL93ap0ZHZTLHwqxRs1GKyZtxNWJEC4GgKKYqO5UA327S
bMioiGNv6pzhNzdlTTZgIMrKxzr3vyb4AM3VvWxZao5uyA4ohJ2qN2wDo6W/kl5r
y5EIZwqbSw9SCnJvnBjK3eDH27XLMDk7kKPPGZRLoJxTAzSrFmyoLUHCNBsmvPmz
7LhNpI4N0hxC8ZPR0CoO26zD2z687XVSkCr0Nlj9ymtwj8M1oD4HQWTzpngEeASq
KGggh+2qSXNM20YxAh80A96pTwi/++gDYMdB8AlpLp1Yg8Pq0Tzc6Ri3yJSYDm0e
h9+w0/JDTTmx7dmuFogjh6CeMZqgUWHdvpgNbmBU9IKIacrMZncP7Ylte8qL48qQ
iV2bWHZTYYIANaZ93wCtpPqwWT8s/IFy7oXjw9R0h2OYYPbEm7GxthtLjsdKLCZu
9EgvmytNrfE=
=JNVV
-----END PGP SIGNATURE-----

--=-ZKDonz5Hhd5i7+cubah6--

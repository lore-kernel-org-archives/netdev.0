From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: phy: Add support for SMSC/Microchip LAN9303 3-port
 switch
Date: Fri, 14 Mar 2014 14:29:36 +0000
Message-ID: <1394807376.20857.41.camel@deadeye.wl.decadent.org.uk>
References: <531057A4.5020607@denx.de>
	 <20140228.130020.2022765291621434648.davem@davemloft.net>
	 <CAGm1_ksPrSjV8+o7LCGDtJz_6qY8bqGuqdpYNHKh_6JO2X0sqg@mail.gmail.com>
	 <20140311.163924.934541574802061078.davem@davemloft.net>
	 <CAGm1_kvTRkCq93BaPgN-MY5Oji3e4is7eq-BtOLv-LJGDCDqPQ@mail.gmail.com>
	 <1394655671.20857.2.camel@deadeye.wl.decadent.org.uk>
	 <CAGm1_kviiz6Y4UjiRXdKNONC9PQbuEHJaDfOpMb8LsuwrEE92A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0WJKbdeTPYcn2jx4/0U7"
Cc: David Miller <davem@davemloft.net>, Stefan Roese <sr@denx.de>,
	netdev <netdev@vger.kernel.org>, "r.meier" <r.meier@siemens.com>,
	"lukas.stockmann" <lukas.stockmann@siemens.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39942 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754378AbaCNO3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 10:29:44 -0400
In-Reply-To: <CAGm1_kviiz6Y4UjiRXdKNONC9PQbuEHJaDfOpMb8LsuwrEE92A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-0WJKbdeTPYcn2jx4/0U7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-13 at 23:42 +0100, Yegor Yefremov wrote:
> On Wed, Mar 12, 2014 at 9:21 PM, Ben Hutchings <ben@decadent.org.uk> wrot=
e:
> > On Wed, 2014-03-12 at 09:43 +0100, Yegor Yefremov wrote:
> >> On Tue, Mar 11, 2014 at 9:39 PM, David Miller <davem@davemloft.net> wr=
ote:
> >> > From: Yegor Yefremov <yegorslists@googlemail.com>
[...]
> >> >> David, what about enabling ethtool to read/write from/to the PHY
> >> >> registers (via passing PHY ID and register number)? I'm trying to g=
et
> >> >> ICplus IP175D running and it has lots of registers, that I would li=
ke
> >> >> to look at dynamically.
> >> >
> >> > For debugging, register dumps are already supported by ethtool.
> >>
> >> Do you mean 'ethtool -e' option? AFAIK it dumps Ethernet controller
> >> regs, if it implements ethtool_ops.get_regs(). What I need are PHY
> >> registers, that I can get via MII interface. ethtool should provide
> >> access to PHY registers like mdiobus_read() and mdiobus_write()
> >> routines.
> > [...]
> >
> > Perhaps, but only as a test/debug interface.  It is not acceptable as a
> > production configuration interface - that needs some abstraction so the
> > same command will work on any switch chip that can support the
> > operation.
>=20
> Sure, I'd like to have this functionality for test/debug purpose.

OK.  First check that mii-tool doesn't already provide what you need.

If it doesn't, please submit patches for ethtool to support MDIO
register get/set.  These should cover both clause 22 and clause 45 PHYs.
Register dump may also be useful, but requires some thought about how to
handle the clause 45 address range (65536 registers per MMD, potentially
2 million per PRTAD).

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-0WJKbdeTPYcn2jx4/0U7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyMSUOe/yOyVhhEJAQogtA/9FGGcSHcy/F5rgWqIRwwb8RTQr31cpZ/z
pK4Grz1+809g8sdr/PjXggv2w0+VG8sCsUgXFgUlCB2cds1FWEsBk/Nss6mNLP2c
jXvfUXEUS2h1BBy+ipxgELocYQUvLlaGQsLjvLM1P7935gmcdpN/TGONuo1hWGGJ
d23AgM7Nx+HxoHXJOPGAUptT0teZOvhtFAVIknkHXwa19rdYOr8ZI7BDWen0uUgK
Hsfy/auKqDsTSAGkP2XcB18LF4ErR2QwelZYUIUeBmNwrBWT/fkF/8l8mbnPpZO8
U7LZtScSoWl6wxcgmAt/ix+b48HxEqJBZ3SxviuAlNJLZankjH53+Vg09Z5SDD/J
aznRbSBkcMYRhG4rUi/bXWktNEAyJZx6qrzMmq7njJ+YvWTDQZj15zBafvMbNcgX
l9NL4EVUZ0NNVhLAQR3La8kohkLK5KVct9g+8M8EaWNoo09nGxuxKsRn+TjyPbQC
Iop4TnK2YuEn8t4xj1vc7k8RTS3XlznuwaEp7y4NwdXhqrw/lDpHoV2gEzbulbZt
1sAfVLFDHps3yYXIZk/mq6R30kaJXU4+U/yzGo+/po0CSzUYjrsjCMjP1Bk45nCL
NPnbSpMU/hof3RXLAAQjkDzzspwJqMuvnB1jpJmvq3h+4TU40xcL2xTqnFlV2FnO
yOAblM+Fja0=
=qXzU
-----END PGP SIGNATURE-----

--=-0WJKbdeTPYcn2jx4/0U7--

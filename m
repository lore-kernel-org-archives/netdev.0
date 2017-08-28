From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v2 05/14] net: mvpp2: do not force the link mode
Date: Mon, 28 Aug 2017 11:40:51 +0200
Message-ID: <20170828094051.GE2568@kwain>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825144821.31129-6-antoine.tenart@free-electrons.com>
 <20170825224312.GD20805@n2100.armlinux.org.uk>
 <20170828065545.GC2568@kwain>
 <CAPv3WKfSGfSAfade163-Q29SR5mxkV19LmYRxVdRBbfW-e-xfg@mail.gmail.com>
 <20170828085152.GF20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="ryJZkp9/svQ58syV"
Cc: Marcin Wojtas <mw@semihalf.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        "David S. Miller" <davem@davemloft.net>, kishon@ti.com,
        Andrew Lunn <andrew@lunn.ch>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory =?iso-8859-1?Q?Cl=E9ment?=
        <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        nadavh@marvell.com, linux-kernel@vger.kernel.org,
        Stefan Chulski <stefanc@marvell.com>,
        =?iso-8859-1?Q?Miqu=E8l?= Raynal
        <miquel.raynal@free-electrons.com>, netdev <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170828085152.GF20805@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ryJZkp9/svQ58syV
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 28, 2017 at 09:51:52AM +0100, Russell King - ARM Linux wrote:
> On Mon, Aug 28, 2017 at 10:38:37AM +0200, Marcin Wojtas wrote:
> >
> > Can you be 100% sure that when using SGMII with PHY's (like Marvell
> > Alaska 88E1xxx series), is in-band link information always available?
> > I'd be very cautious with such assumption and use in-band management
> > only when set in the DT, like mvneta. I think phylib can properly can
> > do its work when MDIO connection is provided on the board.
>=20
> There is another issue to be aware of: if you're wanting to use flow
> control autonegotiation, that is not carried across SGMII's in-band
> signalling.  If you want to use SGMII's in-band signalling for the
> duplex and speed information, you still need phylib's notification
> to properly set the flow control.
>=20
> <plug>
> Switching mvpp2 to use phylink (which is needed for the 1G SFP slot on
> mcbin) will handle all this for you - dealing with both in-band and
> out-of-band negotiation methods, and combining them in the appropriate
> manner for the selected operation mode.
> </plug>

So probably the best move here is to remove this patch, and wait for the
phylink support in the PPv2 driver.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--ryJZkp9/svQ58syV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmj5SMACgkQXE2LyK3b
vNg76Q//VVC4ho9g8x0NSApFh3n2tK1plsF7WulRW3H6KWlglmc6UbMtiVtgwDcM
h6ZcJZCHzVW2t2LaDbPUwOCCFxvTZeLWxRNrwPYFtrUnlwlG7j28Z0st+wYst9Yd
qVsg+nzQfeVnepwI1WBRwd+P8dss5PBySf3QPAewLb2mtNjj53/uQj4gNKxLCMoi
f+lnCbDwhTnPBpGQ9Tj0ghbPkAkx0rimLS+Ep00VIWH/789eST1yYAvunleG+UKt
YfGlw2XhwvegIAo1hlGXxg/o/aATfp/lsAH3m14iYrcld8Yav32VolqorSxXv948
K0TrrV7rhTDleGldNusauK6sBWAplg/ZqwvZwS6ylIkpld9qFcDPTK/mePboG6pi
1zJ0xhWrMXSXN3sFprkypCFxzTiyhvXOEx0RQmXs67F/nF9fgHAOLwePRc3su5QW
0De5sxQfWKaldTl3CElIoF2FI+SqJMr02ZV8hjgRhL1iL80ZD5tD+FkLVyWt+P28
LJ1a0FQTg7YbgXKVWrCN+/42qlqhCFOIczoIkAvn+odVXX/eiPHLxUu+wkiHeUPR
qpTGHja0MC2JYF4tG6HeLwDBbXwIzgQMToSqCNOOPyawFgpasYDbf7s5WIQ4b3yt
Q9Dogr8n+vZPAa/x0YGzSgABJztmq4urDkhwa9d5916PhMwJ4gM=
=YR98
-----END PGP SIGNATURE-----

--ryJZkp9/svQ58syV--

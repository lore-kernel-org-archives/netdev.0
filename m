From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v2 05/14] net: mvpp2: do not force the link mode
Date: Mon, 28 Aug 2017 13:32:03 +0200
Message-ID: <20170828113203.GF2568@kwain>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825144821.31129-6-antoine.tenart@free-electrons.com>
 <20170825224312.GD20805@n2100.armlinux.org.uk>
 <20170828065545.GC2568@kwain>
 <CAPv3WKfSGfSAfade163-Q29SR5mxkV19LmYRxVdRBbfW-e-xfg@mail.gmail.com>
 <20170828085152.GF20805@n2100.armlinux.org.uk>
 <20170828094051.GE2568@kwain>
 <20170828110624.GG20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="Pql/uPZNXIm1JCle"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Marcin Wojtas <mw@semihalf.com>,
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
In-Reply-To: <20170828110624.GG20805@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Pql/uPZNXIm1JCle
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 28, 2017 at 12:06:24PM +0100, Russell King - ARM Linux wrote:
> On Mon, Aug 28, 2017 at 11:40:51AM +0200, Antoine Tenart wrote:
> > On Mon, Aug 28, 2017 at 09:51:52AM +0100, Russell King - ARM Linux wrot=
e:
> > > On Mon, Aug 28, 2017 at 10:38:37AM +0200, Marcin Wojtas wrote:
> > > >
> > > > Can you be 100% sure that when using SGMII with PHY's (like Marvell
> > > > Alaska 88E1xxx series), is in-band link information always availabl=
e?
> > > > I'd be very cautious with such assumption and use in-band management
> > > > only when set in the DT, like mvneta. I think phylib can properly c=
an
> > > > do its work when MDIO connection is provided on the board.
> > >=20
> > > There is another issue to be aware of: if you're wanting to use flow
> > > control autonegotiation, that is not carried across SGMII's in-band
> > > signalling.  If you want to use SGMII's in-band signalling for the
> > > duplex and speed information, you still need phylib's notification
> > > to properly set the flow control.
> > >=20
> > > <plug>
> > > Switching mvpp2 to use phylink (which is needed for the 1G SFP slot on
> > > mcbin) will handle all this for you - dealing with both in-band and
> > > out-of-band negotiation methods, and combining them in the appropriate
> > > manner for the selected operation mode.
> > > </plug>
> >=20
> > So probably the best move here is to remove this patch, and wait for the
> > phylink support in the PPv2 driver.
>=20
> I've nothing on that specifically for the mvpp2 driver - what I have is
> for mvneta and the Marvell mvpp2x driver, with GMAC support extracted
> from mvneta (that last bit is rather dirty at the moment so not
> published anywhere, and doesn't cater for PP v2.1 at all.)
>=20
> I ought to have posted the mvneta part of the phylink patches, but I
> didn't get around to it early enough in this cycle - there are probably
> quite a number of conflicts with net-next now, so I think it's too late
> to submit it for mainline.
>=20
> I know Andrew has already looked at them in my git tree as part of the
> review of phylink when that was merged - which should be adequate to
> give an example of how to implement it for the mainline PP v2 driver.

OK, good. When looking at the phylink support in the PPv2 driver we'll
look into what you did for mvneta (I saw it as well on your tree). In
the meantime I'll respin this series without this patch.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--Pql/uPZNXIm1JCle
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmj/zMACgkQXE2LyK3b
vNhxZg/+KimS8Jab0Oqy7rA4pwd6kUSUJbg5cVLOBb2929Mva8uc1ZxnQ8gfWYS9
22mtWznqLFa8Bb1L1+ox0dciTnFsOwKsVVzYudWVnPGqpFfRs3TAlHNAOiwOHN8i
avw0c5E7WegkP7ya/yshjh5HaDmy6H08v59UPlwN2C8uQ3ieXYWxNKNUZbku9nrs
SzGG6MGhaHefQ5d1cMs71h4pnYJUDuS+VXULNMCWIuKEVi5rehYYtT4zXhcVLA0L
qFEKzwm+PdqcNJgLo+c0pdd64MHDJnf6j2z47bL2RchzcwPOVPaAJIN1XO7YQtuW
ys2Grk6fnHqPP5tB087uonnpd9C5d7DFlonOrw2DKNj3ozUijyk/kly2VPessXrY
1Pd7H79EZgJxCT/WloCrfRzlE9PqtkY7cQruEOIpAEHJQpwHO6yGy3GELSOt676G
WhHsOY2CO8+ZINefJDQmfqFn4Hm/W/ObRsy7BqRNleVenR3+RX4EdfYIJCkGR5AL
ciiWfIrNBms7y7AQfqjcB4CvsPq0PTzgoIc5SWJAV9y/ARf/9NxorQrK0deQ4NzO
oEDvWZggO+6u4XJ/r9ANR1gHVT2SkQhGcw44yK7QOaox+OFtZTS5lp7oCLUQi3fw
FLwRo9JaFNI0nMALpuLawYjfBZnVD8ks9TT68NTDOmmN3gzJDOk=
=CETd
-----END PGP SIGNATURE-----

--Pql/uPZNXIm1JCle--

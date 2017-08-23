From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Wed, 23 Aug 2017 09:49:42 +0200
Message-ID: <20170823074942.yt3c5gvnmdw5pqge@flea.home>
References: <20170820065757.GA6081@Red>
 <20170820142545.GB24150@lunn.ch>
 <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
 <20170821132015.GB1703@lunn.ch>
 <20170821133104.qvrhvwin2rdg4aqo@flea.lan>
 <20170821142321.GE1703@lunn.ch>
 <CAGb2v64E4T=1ff3POGuXZA=MvjGAnKQ6OF6A3sT_cU-=jh6zNw@mail.gmail.com>
 <bfe784b6-5137-8fcd-dbd0-ad96974f4060@gmail.com>
 <20170822181140.GA11596@Red>
 <352ae66b-78a4-e88b-4544-a8edd9390b0c@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="5h36v2pido6imtht"
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Chen-Yu Tsai <wens@csie.org>, Andrew Lunn <andrew@lunn.ch>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <352ae66b-78a4-e88b-4544-a8edd9390b0c@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5h36v2pido6imtht
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Florian,

On Tue, Aug 22, 2017 at 11:35:01AM -0700, Florian Fainelli wrote:
> >>> So I think what you are saying is either impossible or engineering-wi=
se
> >>> a very stupid design, like using an external MAC with a discrete PHY
> >>> connected to the internal MAC's MDIO bus, while using the internal MAC
> >>> with the internal PHY.
> >>>
> >>> Now can we please decide on something? We're a week and a half from
> >>> the 4.13 release. If mdio-mux is wrong, then we could have two mdio
> >>> nodes (internal-mdio & external-mdio).
> >>
> >> I really don't see a need for a mdio-mux in the first place, just have
> >> one MDIO controller (current state) sub-node which describes the
> >> built-in STMMAC MDIO controller and declare the internal PHY as a child
> >> node (along with 'phy-is-integrated'). If a different configuration is
> >> used, then just put the external PHY as a child node there.
> >>
> >> If fixed-link is required, the mdio node becomes unused anyway.
> >>
> >> Works for everyone?
> >=20
> > If we put an external PHY with reg=3D1 as a child of internal MDIO,
> > il will be merged with internal PHY node and get
> > phy-is-integrated.
>=20
> Then have the .dtsi file contain just the mdio node, but no internal or
> external PHY and push all the internal and external PHY node definition
> (in its entirety) to the per-board DTS file, does not that work?

If possible, I'd really like to have the internal PHY in the
DTSI. It's always there in hardware anyway, and duplicating the PHY,
with its clock, reset line, and whatever info we might need in the
future in each and every board DTS that uses it will be very error
prone and we will have the usual bunch of issues that come up with
duplication.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--5h36v2pido6imtht
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZnTOVAAoJEBx+YmzsjxAgk3oP/AheSyfX+4cOfLLtZ2rOOZ1r
jIZuZzbMqDwB4t2q8KmbNpcogJBVr1wp+RkdZIz/jF4T+4DjW03h1EJ/o31BFaXm
1T99ua2ZWoZ98xwotzqfWYlJ2l7yu3YwO69ei/aQF5m9OYgxsXUohd9W6KYkfzCW
TCAKmxpm3awub+3aTCQNbcrcIWRezS2+SdrrlC7trqqyfsE0YAjA/bbO+dqHAPU1
SruYUg6x4WElxpgSjhOWwsGUP8PkIf5h52sppC1pHWmM26s0z2PP4vPqlq6P4u8E
G5q0RokK0oug2SVNkng7d0TXA7PaTn8/qtzb29meaPlmqyLJZjW+mzvQnt0Ekhji
tdTRn47JlUeyeSwy4GH06MX9RC03aIYjCAjalY7AFNNiHVVDrwP8kCAcgUBTwF3h
nRf+EhPs4UUqv2xhtICs5/MaUiN1DCDisEsWQbwckDBba8HNGDG72kHGEQBHPrjx
56Df5ywTyteuQRXCJcdObI+1eKIgt1IlNtjLQqdiiXlgOYhjb3158G8N2pBFLZ8k
5TqxRnML8JAW6rgfXLt5YwUMvJx7P57GPkfzm9I+jEyIBuyOchPmWFDUuB7W51IF
dyS/kYqhM8xxNOM50nALnYH+AxgPlpmXFOzVMMrqon1T0EkeLP7K7dXIHo2X4c9g
+REUVNFt9N/4G7C1qGPE
=8Iuh
-----END PGP SIGNATURE-----

--5h36v2pido6imtht--

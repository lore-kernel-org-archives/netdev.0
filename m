From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v3 3/4] net: stmmac: register parent MDIO node for
 sun8i-h3-emac
Date: Mon, 21 Aug 2017 15:31:04 +0200
Message-ID: <20170821133104.qvrhvwin2rdg4aqo@flea.lan>
References: <20170818122118.4925-1-clabbe.montjoie@gmail.com>
 <20170818122118.4925-4-clabbe.montjoie@gmail.com>
 <CAGb2v66KcZkiDDHryMmVzm4WroXePPy3V44SLpVdoO3ZEjgC=g@mail.gmail.com>
 <20170819185025.GB13266@Red>
 <20170819203836.GA21567@lunn.ch>
 <20170820065757.GA6081@Red>
 <20170820142545.GB24150@lunn.ch>
 <CAGb2v67hQXSoCKP7qW+KRUYX+0djQ1Z23cQ67Lyg6G7ozGyfGQ@mail.gmail.com>
 <20170821132015.GB1703@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="f3m3hnntahsrss3n"
Cc: Chen-Yu Tsai <wens@csie.org>,
        Corentin Labbe <clabbe.montjoie@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        devicetree <devicetree@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170821132015.GB1703@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--f3m3hnntahsrss3n
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Mon, Aug 21, 2017 at 03:20:15PM +0200, Andrew Lunn wrote:
> > With our hardware, and likely Rockchip's as well, the muxed connections
> > include the MDIO and MII connections
>=20
> Ah, i did not realise the MII was muxed as well. Then i agree, an MDIO
> mux is wrong.
>=20
> However, please try to make the binding not look like an mdio mux. We
> don't want people misunderstanding the binding and thinking it is an
> mdio mux.

Do you have any suggestion on what the binding would look like?

All muxes are mostly always represented the same way afaik, or do you
want to simply introduce a new compatible / property?

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--f3m3hnntahsrss3n
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZmuCXAAoJEBx+YmzsjxAg1xoP/3dZHOxLjKurUxT4h2Ui17Ww
52KzoyH8bHYQiuNvmlwLS+0WTcAnyO8AK13Ux/gH4vN4SWVEP2dKFh00Jmmkdfn4
iO2XB2GZ7eUCIfdzJSWc0x/foH0T9jdv0MWMtQP0sROLzjWFUcCWBhZ1izPzqK9s
q8St+JMv6LCgQNKRsVa/JPTDxjsIVJfWY975A5yhlRDw5btETs3FyvdNERq4/n5D
mbDBoC9qF7x48ZgWXjU+8ujDURIR730nN5dwnUbwclOGaSsSqUEWyY8dTQ7FdWYg
2hHu2jZ1vW0koap7yrOGVrWjr9KoYxnYtfxpDc/4rlVK1xtXyLk/KrSVf6GrsX4/
QyUx+kaobnOeagPmRaAgjVnq93DcPlr4a+LknMuHqH+cn/6Agg7LDAxecD/xdOd/
hYkwE29W085mCleFxl322oTD5NJyv3gdDrXyCwKXzyJK6AGMkSV/NojUxubO7Mbv
F1b68MyZkhi3rc2Cah0NN0vn3ULYFNdBqWmKgnaAVD+QN+o3noWSS5GdkhoJ5Mha
laSapjaHIZn6yVl7JjxwjuyznK3B+9JT3eoGJqcGOLUA5C798iPlUG5LS6PLkgmC
N1FGr4MgdULgzUnfSKiylDXtHA7Wytqx5RLtMs3ishzEywSywqNUiHHd7uuGi47l
q5FHn7wPbb+KWYhgBUlY
=sPdg
-----END PGP SIGNATURE-----

--f3m3hnntahsrss3n--

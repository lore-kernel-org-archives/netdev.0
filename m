From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v3 02/13] phy: add the mvebu cp110 comphy driver
Date: Wed, 30 Aug 2017 08:36:45 +0200
Message-ID: <20170830063645.GE31552@kwain>
References: <20170828145725.2539-1-antoine.tenart@free-electrons.com>
 <20170828145725.2539-3-antoine.tenart@free-electrons.com>
 <d84fd9c4-d214-1140-09d8-75f2fa64a850@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="19uQFt6ulqmgNgg1"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, andrew@lunn.ch, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d84fd9c4-d214-1140-09d8-75f2fa64a850@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--19uQFt6ulqmgNgg1
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kishon,

On Wed, Aug 30, 2017 at 10:49:13AM +0530, Kishon Vijay Abraham I wrote:
> On Monday 28 August 2017 08:27 PM, Antoine Tenart wrote:
> > +
> > +static int mvebu_comphy_set_mode_sgmii(struct phy *phy, enum phy_mode =
mode)
>=20
> the mode need not be passed as argument here since this function is only =
for
> sgmii mode.

Sure, I'll remove it.

> > +{
> > +	struct mvebu_comphy_lane *lane =3D phy_get_drvdata(phy);
> > +	struct mvebu_comphy_priv *priv =3D lane->priv;
> > +	u32 val;
> > +
> > +	mvebu_comphy_ethernet_init_reset(lane, mode);
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_RX_CTRL1(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_RX_CTRL1_CLK8T_EN;
> > +	val |=3D MVEBU_COMPHY_RX_CTRL1_RXCLK2X_SEL;
> > +	writel(val, priv->base + MVEBU_COMPHY_RX_CTRL1(lane->id));
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_DLT_CTRL(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_DLT_CTRL_DTL_FLOOP_EN;
> > +	writel(val, priv->base + MVEBU_COMPHY_DLT_CTRL(lane->id));
> > +
> > +	regmap_read(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), &val);
> > +	val &=3D ~MVEBU_COMPHY_CONF1_USB_PCIE;
> > +	val |=3D MVEBU_COMPHY_CONF1_PWRUP;
> > +	regmap_write(priv->regmap, MVEBU_COMPHY_CONF1(lane->id), val);
> > +
> > +	val =3D readl(priv->base + MVEBU_COMPHY_GEN1_S0(lane->id));
> > +	val &=3D ~MVEBU_COMPHY_GEN1_S0_TX_EMPH(0xf);
> > +	val |=3D MVEBU_COMPHY_GEN1_S0_TX_EMPH(0x1);
> > +	writel(val, priv->base + MVEBU_COMPHY_GEN1_S0(lane->id));
> > +
> > +	return mvebu_comphy_init_plls(lane, mode);
> > +}
> > +
> > +static int mvebu_comphy_set_mode_10gkr(struct phy *phy, enum phy_mode =
mode)
>=20
> same here..

And here as well.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--19uQFt6ulqmgNgg1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmmXPoACgkQXE2LyK3b
vNganw/8CxbycjP1OeR53XIk4l+jxp6Rvg/GV9ETUyO2RMEerQ+W+kw1ApwCN86t
p6PVGFXyT0rrfv19h0iYsstAjGeEumqtRt7JeS2ZwxueVTdHKiu2HCYcOacQhc1H
WjLM0QdIXJq4T75fTlBVcYYw2J8B+6bdRcvHYyZN2TLTxgroi1KHGt6aLGOEASBk
m4YuakCESTZoJgYbxWREv9lT3tCf3QJEOIk7s+UW3O18Gfwm/bVyVSuMx6qWnrSD
eweLbiWJpscVYSuPUyUo3QjLoI1p1kJZIvutOfy2HoZJBu464HEjdnm3tFs0SJh6
lyKXXGt2jx7p1pmwY+UimuXDQPZeyhIXamWUckSr++nrAN+YvxmfxJ/OUBkyXf6C
i8dzp1yJ/UXOkZ4Uy3Njs9BGuGy3yxOA5tJJ8KgpgExzWnMnxmP8UlyLjLedR5vD
yFXiNP9AB0+HMhGWjwuPQPrWN1aVv9MtqaBrMT5oHDlaJRRgHYngswgXuVvOIPwx
pYEl0ISUGnRs1V2rSubF2P/oA6CnrqcfT/xLyrCj8/RNY/GJVFJDltB+z+qVTMwb
Xo8FfPZMf7DV2cIP6jGpPwpiRVbzwwzbpRKZuRJSz8Df9O7yUBL55FHQuke2ocnb
aeIAZDXgFa7dCWuSjoTmgeDTKih6IwbFi0h9Ms6Ln110wgjja2c=
=UCMg
-----END PGP SIGNATURE-----

--19uQFt6ulqmgNgg1--

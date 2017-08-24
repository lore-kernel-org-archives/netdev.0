From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 02/13] phy: add the mvebu cp110 comphy driver
Date: Thu, 24 Aug 2017 15:44:44 +0200
Message-ID: <20170824134444.GA28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-3-antoine.tenart@free-electrons.com>
 <20170824133922.GC8022@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="oyUTqETQ0mS9luUI"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824133922.GC8022@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, Aug 24, 2017 at 03:39:22PM +0200, Andrew Lunn wrote:
> > +static const struct mvebu_comhy_conf mvebu_comphy_modes[] =3D {
> > +	/* lane 0 */
> > +	MVEBU_COMPHY_CONF(0, 1, PHY_MODE_SGMII, 0x1),
> > +	/* lane 1 */
> > +	MVEBU_COMPHY_CONF(1, 2, PHY_MODE_SGMII, 0x1),
> > +	/* lane 2 */
> > +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_SGMII, 0x1),
> > +	MVEBU_COMPHY_CONF(2, 0, PHY_MODE_10GKR, 0x1),
> > +	/* lane 3 */
> > +	MVEBU_COMPHY_CONF(3, 1, PHY_MODE_SGMII, 0x2),
> > +	/* lane 4 */
> > +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_SGMII, 0x2),
> > +	MVEBU_COMPHY_CONF(4, 0, PHY_MODE_10GKR, 0x2),
> > +	MVEBU_COMPHY_CONF(4, 1, PHY_MODE_SGMII, 0x1),
> > +	/* lane 5 */
> > +	MVEBU_COMPHY_CONF(5, 2, PHY_MODE_SGMII, 0x1),
> > +};
>=20
> Do other Marvell SoCs re-use this IP? Maybe add cp110 to the name here
> to indicate what SoC this configuration belongs to? I guess at some
> point, the compatible string will be used to select the correct table
> for the hardware variant.

OK, I'll rename the variable mvebu_comphy_cp110_modes.

> > +static const struct of_device_id mvebu_comphy_of_match_table[] =3D {
> > +	{ .compatible =3D "marvell,comphy-cp110" },
>=20
> Is that specific enough? It seems like this table is easy to change in
> the VHDL. Could there be another cp110 with a different configuration?

As far as I understand CP110 is the name of the CP, should there be
another one it should be named differently. But I can't be 100% sure,
you never know what comes next :)

How would you name it if not "comphy-cp110"?

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--oyUTqETQ0mS9luUI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlme2EwACgkQXE2LyK3b
vNjU3RAAkUiU8+x7mPDC6sqWZkOH6hgP6N82ESZZcbI3LmK/CW6n0xy0IRQAFWSx
p2I/8WF93bAAsaktVDzv21AwYZS5bKiQmeVoXaFL5uTxbnvecGRxOhdG7aBZhfhW
wz68olZtrIq2Xl1nasBCOYLJ2UWHgg+jQu0vH5WLMyMjXl1a+e9x8HckH+7CAr4q
vEHStB3H8ezWzAz3YWo1kW5pB9qoSgX2nf0bN0JIc4aqITbMAXIVhYZTvIiI24zw
RdOR5zFTm+LfDfMdTwCEd5peZArdYnnyPHiCYpha2gV9snWHHrlaZzKvD191DAl/
sXdCSiQqZBe3oCQPtVeSPhH4dM6U5+QPYPKpMQM0tNnY+/ss2pj+9M8fOt376CWQ
FzbPh8xl+lj905qgpr4ndquT9F+RX6OnsdwxczpLu1L+IVsFA2J9NIedNQekRcA+
lLxime0cZppDhuJxczRn7Xtoi99V/d280kdWIndpSBinGZBGOwqePkrDFYGe0T7v
B4lIxCkhaOiwf8mHePg/LRTJHz+VRvozSNWW+LS1NRDans1msvAtPX4qFQSyAyUl
Xnr6EkzRTuUD2ptoZQQ2L51eQRLI2mDVQ8Mnrmx3nT4WD5X5daKyg+s80Phlvjqa
4v/JZ7Wi29lK5CQwGwp95mH9jQsSapzQdtvLT7FlSyoOpkG08oQ=
=HqTf
-----END PGP SIGNATURE-----

--oyUTqETQ0mS9luUI--

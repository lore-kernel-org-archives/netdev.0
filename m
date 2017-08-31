From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 2/3] net: mvpp2: use the GoP interrupt for link
 status changes
Date: Thu, 31 Aug 2017 15:52:55 +0200
Message-ID: <20170831135255.GA26758@kwain>
References: <20170831071256.18416-1-antoine.tenart@free-electrons.com>
 <20170831071256.18416-3-antoine.tenart@free-electrons.com>
 <20170831134724.GO22289@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="pf9I7BMVVzbSWLtt"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170831134724.GO22289@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pf9I7BMVVzbSWLtt
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, Aug 31, 2017 at 03:47:24PM +0200, Andrew Lunn wrote:
> On Thu, Aug 31, 2017 at 09:12:55AM +0200, Antoine Tenart wrote:
> > +static void mvpp22_gop_unmask_irq(struct mvpp2_port *port)
> > +{
> > +	u32 val;
> > +
> > +	if (port->phy_interface =3D=3D PHY_INTERFACE_MODE_RGMII ||
> > +	    port->phy_interface =3D=3D PHY_INTERFACE_MODE_RGMII_ID ||
> > +	    port->phy_interface =3D=3D PHY_INTERFACE_MODE_RGMII_RXID ||
> > +	    port->phy_interface =3D=3D PHY_INTERFACE_MODE_RGMII_TXID ||
>=20
> phy_interface_mode_is_rgmii()

Right, and you already made that comment before... I'll fix it.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--pf9I7BMVVzbSWLtt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmoFLUACgkQXE2LyK3b
vNgZag/+NSqttzqvCO29x+GvIKjEJw8hEw1T8Q12xCeOnMu34e5B34bAYSoDvd0D
jgi4b5pMsEaE49vyHojTbr68lIxkSQyi0brXS0ugVDXsHGEXvEtQdFpOARvc8zyC
LvvIWmnhHD+vWA7l8odaseVQnZJONTMdo1SCc/7R6OmJoaHbfzal7FegrV/zLcOF
eqks6xKM9j/Cx1kPP27XoebM57oiW7GA2QPPI9P686SPaWxwvql/uV3OWBx34NKL
Yt5BFKwQGXoiEO/NKxd45fjwGpOCJkDEotBfP71BeHe/DLK0pL5+3RWfwAYWi3qj
gzSOUo1zVQjsKtIK5HE/gM0ol0MvMsKt+IypERGYeJ+9xRtTmlIbaCPtysSqGJa2
mhaZ/Mrq3v7psPEMHEp/V7L31O6fPqvg7TXzI9JizPIA9MeOCfv7e2Qstbh/Hctj
Oxv9vCeZ0Q77hgjRVVH2tD+PZU3K2EXYDTimjudzw8UGXswGJVP0he5U4I45Kl8o
LUFq4x3Y2pTwZjFAXIeshuN5XdkzX/Ky7ieM7X2SmXC0KO63QoBQCy/W+hTeqvYt
vrdoxUXBaWiFqkb4fGgd5nRtyn1cMPreeXVuqSYGZUA3f5zCu5gfkAxDMVG3iUHc
yICw/y7F/yueoHzZrvjT0WoVLmhGXfdYYe8bXR8eIV9x6Yhs3wQ=
=iw0B
-----END PGP SIGNATURE-----

--pf9I7BMVVzbSWLtt--

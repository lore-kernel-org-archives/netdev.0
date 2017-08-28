From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v2 09/14] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Mon, 28 Aug 2017 08:52:27 +0200
Message-ID: <20170828065227.GB2568@kwain>
References: <20170825144821.31129-1-antoine.tenart@free-electrons.com>
 <20170825144821.31129-10-antoine.tenart@free-electrons.com>
 <20170825224616.GE20805@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="FkmkrVfFsRoUs1wW"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170825224616.GE20805@n2100.armlinux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--FkmkrVfFsRoUs1wW
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Russell,

On Fri, Aug 25, 2017 at 11:46:16PM +0100, Russell King - ARM Linux wrote:
> On Fri, Aug 25, 2017 at 04:48:16PM +0200, Antoine Tenart wrote:
> > This patch adds logic to reconfigure the comphy/gop when the link status
> > change at runtime. This is very useful on boards such as the mcbin which
> > have SFP and Ethernet ports connected to the same MAC port: depending on
> > what the user connects the driver will automatically reconfigure the
> > link mode.
>=20
> This commit commentry needs updating - as I've already pointed out in
> the previous round, the need to reconfigure things has *nothing* to do
> with there being SFP and "Ethernet" ports present.  Hence, your commit
> message is entirely misleading.

That's right. I'll update the commit message.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--FkmkrVfFsRoUs1wW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmjvakACgkQXE2LyK3b
vNihgw/+MPpN/z8xzW5SB2AKrDwfjy76fpFhv6vtzm5Nv14jEKl9Kr7GgskU5Gpl
sjmUyTYVqcE7ZzNIv2MQJgZanDIhFElPLpTUUQwO08PfHqHjCnMdNGQSioRGwAPV
HpO/VOdTuOR96TbYjFFwxXQEH1C3BC8PuyBMcJT8VLysEvAHeV2GM6iyBPP79O1B
uHKmFmtZB3ulMwy1UXxTCgBkSoeN7X+jyXQlF5vu3Rqr22FLED+z2lsUS5zxjb1n
dVOLq5xfPE+S7AwnACxnyat+HSlrp21+Rr/zpsmkbScVhzFxuvzCEF6WQ4aUQi/x
2c/cLauXBvvZIcedmlL96nab7dT/iF+unDoUVIDZGtjM/4wGNROGaZW+dAC820+z
XwnBQlxwV3CcHJP64Q7DFt7/T/VtE5bSGOTPyQ/XLwI2gFuxrFWHMcqsQx+BzvUL
gSvjJbcDM6l+gDXkwDShohH4HnkPkVTismU1vc/k5LtHKtL7TlSiHR9+jc+UyUj+
JmOhOn1T6uhA1AVD/StnK6dApLNr7qW2tfN8uH7tXe5rEr4JBors+ydRcyhtxLTo
SQtCG4MHAvG6BsM4CAeWhrH9BL9QYa1WNDQMgH5UyIbqOqGGsaHjPfbKUeC/QZCg
ye8GZTDAF3VtYD0ol38IVo83yDHvyvS5jRQxFmZVWxuemS6waJE=
=5Qwu
-----END PGP SIGNATURE-----

--FkmkrVfFsRoUs1wW--

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 09/13] net: mvpp2: dynamic reconfiguration of
 the PHY mode
Date: Thu, 24 Aug 2017 17:52:41 +0200
Message-ID: <20170824155241.GF28443@kwain>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-10-antoine.tenart@free-electrons.com>
 <20170824145609.GJ8022@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="H4SyuGOnfnj3aJqJ"
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
In-Reply-To: <20170824145609.GJ8022@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--H4SyuGOnfnj3aJqJ
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, Aug 24, 2017 at 04:56:09PM +0200, Andrew Lunn wrote:
> On Thu, Aug 24, 2017 at 10:38:19AM +0200, Antoine Tenart wrote:
> > This patch adds logic to reconfigure the comphy/gop when the link status
> > change at runtime. This is very useful on boards such as the mcbin which
> > have SFP and Ethernet ports connected to the same MAC port: depending on
> > what the user connects the driver will automatically reconfigure the
> > link mode.
>=20
> I would expect each of these external Ethernet ports to have its own
> Ethernet PHY. Don't you need to disconnect from one Ethernet phy and
> connect to the other Ethernet PHY when you change external Ethernet
> port?

That's the other way around. The engines outputs (say GoP#) are
connected to the comphy inputs. In the SoC. Then there's a single output
of this comphy lane to the board. So when switching modes, you do not
have to connect to a different Ethernet PHY, it's the same.

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--H4SyuGOnfnj3aJqJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlme9kkACgkQXE2LyK3b
vNiaCQ/+KbLtiGCKctD8Gx4bRTgwuti+8ZZmdbpd7uVj7bENY3UWrm01pQMphc2J
YQR7zMaJbFr0D0l1m/Vo0kCIZCxBigwOf1vaT67RhjYn145o3NBtxKFvV/ddgdrv
9k4xnbzF7Fkj7z0pD6ZiaRzgQBZSAcz0TFqgR7J1R4VJ35hI+PgZg6v+HAU+rqBl
lQQ5W3/onRITntuw++od2/QV8JrNPixkGgslnlZntujYKDvqp+m/a9fe2Eayq8s4
cuj/rnlalXfOOsOLV/J0wxlbDR0FdnVSmdcq8YjjkZKhwP7s5RynWOAUutofV0rh
2r+rL0les9Ic+6bwS1RmlOjXqVfuQqpWbraiUbvnRgeIacV/yjTXpUQtiLjmuTyL
K+B49GmRSZiqq1FAw24rEkoMrGM6W7uY6X4d6vKSDXREE+wFgFt4aTatADJSqp6T
/qoAjT7GTLSjDpCXocuJ9O3GsM4bI5EuGvB1m5U8NZJHynaQsYCds8VPfbV1wOdR
yMbrrqTMN0ImVI/I89F9ihGj1YU0Duv+3CSQnJpeUiO0RWpq7zv6eq9iWz+Mfs2v
+gLB1hURhBXoNSDSEDJ/WpA8o4dqCE7jBTYrJ8RqbOcenLXiNYTf/e5oqtXVpO/m
MF9yXTPIUbsZzhRA0JHEGjOOcRLK5QvFntqNDQsQrQ9Luny22fc=
=p60m
-----END PGP SIGNATURE-----

--H4SyuGOnfnj3aJqJ--

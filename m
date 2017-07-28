From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 08/18] net: mvpp2: make the phy optional
Date: Thu, 27 Jul 2017 18:50:33 -0700
Message-ID: <20170728015033.GD24728@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-9-antoine.tenart@free-electrons.com>
 <20170726162000.GJ12049@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="qGV0fN9tzfkG3CxV"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:33261 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751642AbdG1Buh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 21:50:37 -0400
Content-Disposition: inline
In-Reply-To: <20170726162000.GJ12049@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--qGV0fN9tzfkG3CxV
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, Jul 26, 2017 at 06:20:00PM +0200, Andrew Lunn wrote:
> On Mon, Jul 24, 2017 at 03:48:38PM +0200, Antoine Tenart wrote:
> > SFP ports do not necessarily need to have an Ethernet PHY between the
> > SoC and the actual physical port. However, the driver currently makes
> > the "phy" property mandatory, contrary to what is stated in the Device
> > Tree binding.
> >=20
> > To allow handling the PPv2 controller on those boards, this patch makes
> > the PHY optional, and aligns the PPv2 driver on its device tree
> > documentation.
>=20
> It is an architectural question...
>=20
> but with the boards i have with an SFF port, i actually use a
> fixed-phy to represent the SFF. Then nothing special is needed.

I was not aware of the fixed-phy, that might work for us here.
Thanks for the hint!

> Also, Russell King posted his phylink patches. Once accepted, you are
> going to want to re-write some of this to make use of that code.

And there's that as well.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--qGV0fN9tzfkG3CxV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAll6mGkACgkQXE2LyK3b
vNj8wg/9HTBtUGk6j2aXp70BEJGCJRRS4O+ApOKAaYZ+QcgWFMSHKg6NRzEEi1my
px/+TM3QawDAyUll12LQGjdyxmZPywmx/PZjB9b0wdBy3risOk6HQbj2buE4dbRP
aT3flTeK6vqC8mYnkoTaTnxkPmbNpPba5jQtmxCs4nwgZDntyxVNeLX7riHzEirF
FiZYzD1OQJf/CXJFvaMUvilRmIwNykY+QN2vrlb0WsYfQo6i3a/UMDlpQzwSLTO3
5yXLfoawk8zo4tpv4PSL+J+tMXNMUwCDQq/hc3cusWqJv1K9THmCGMyTqHf4YHr4
T6BK62PWt++qYtgLdbQkwWCnTxLAgtL+SV//ESPDDvYMqLv1P9R7/ylaaX/NcZI6
8LlEN6Z1hO3yDgnlrgS0jYJgis38XihjECcxfNGly62PukvRZGNDNnkRJmk5oEh9
Bia/wZyZsdxfuOpNYC+bIfVjS8GfoGTZBrtvMahFaDhUTj/+2atFWmKzsUTb4TpA
JF2yrEyuxFpEK2Phzo0c1lUySRzoO8FcCZ5VwY3XZ6nRXxbPRMLgn+fX1LSD6F5/
mLTkSnu4qXfehBc9Xn35n+oKMtX6LTvtaPsnkNco19wGxcvarQsnuFY8cV+5xjMv
x+OjWmQuivLUfQfNdIB/Yjcr8iaW7VZOLzdkp7K0YRPdfnORo4E=
=if/G
-----END PGP SIGNATURE-----

--qGV0fN9tzfkG3CxV--

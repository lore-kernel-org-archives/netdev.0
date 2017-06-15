From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v4 10/11] dt-bindings: orion-mdio: document the new xmdio
 compatible
Date: Thu, 15 Jun 2017 08:55:26 +0200
Message-ID: <20170615065526.GA4773@kwain.lan>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
 <20170614154911.14510-11-antoine.tenart@free-electrons.com>
 <20170614163537.GO15847@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="envbJBWh7q8WU6mo"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:51865 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdFOGz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 02:55:28 -0400
Content-Disposition: inline
In-Reply-To: <20170614163537.GO15847@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, Jun 14, 2017 at 06:35:37PM +0200, Andrew Lunn wrote:
> On Wed, Jun 14, 2017 at 05:49:10PM +0200, Antoine Tenart wrote:
> > =20
> >  The Ethernet controllers of the Marvel Kirkwood, Dove, Orion5x,
> > -MV78xx0, Armada 370 and Armada XP have an identical unit that provides
> > -an interface with the MDIO bus. This driver handles this MDIO
> > -interface.
> > +MV78xx0, Armada 370, Armada XP, Armada 7k and Armada 8k have an
> > +identical unit that provides an interface with the MDIO bus or
> > +with the xMDIO bus. This driver handles these interfaces.
>=20
> This patches is looking good now. One nit. The description above
> suggests Kirkwood, Dove, Orion5x, MV78xx0, Armada 370 and Armada XP
> all have xmdio. Maybe better wording would be:
>=20
> The Ethernet controllers of the Marvel Kirkwood, Dove, Orion5x,
> MV78xx0, Armada 370, Armada XP, Armada 7k and Armada 8k have an
> identical unit that provides an interface with the MDIO bus.
> Additionally, Armada 7k and Armada 8k has a second unit which
> provides an interface with the xMDIO bus. This driver handles
> these interfaces.

Agreed, your description is better :)
I'll respin this patch only, if there is no other comment.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--envbJBWh7q8WU6mo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZQi9cAAoJEFxNi8it27zYp9QP/1r9sqyUCbtFggn2ACeVs/dm
gIV5zLp3jcqXZ1+zO82Og1wMp7tCCTdkgpYqPB1fim3/FX/kqUvJ0jZ7pbhNreLC
dD1TzU1kT2rhsoYE6Xl8+3GfAnBzc4Buh+rUej3/vMi6o9EhB3/3i0nENb0gk9ui
XQBiyXymFzNsgx+tGQkOiZSQ35Z9C5Zft5R2R04moSEYfMCZjWFWFTqKlcoWTtZh
u6OeKgm6308qBG9dR7DtvGbEasrtg8EQJ3gOEBM8YBHyyKtSmkC5sJySm8OKF4Wf
i3lKLl2uuSHt/WVyz8KOkS6COfZT7hFNPxGNheF4IG0+4QMpyR9TiNmfRtCDavCy
fTJDv9+ZKwqx2az5M4F3ePtDgAaeYkYQDC7+JutsraKb4T+9nvQoslsnp+9navO0
8qjo7+cDqfpuwo9yVpJLjYXC/8mGD2O6Id0U0fWhWVL2WfR8f6qr8SkyjBpiSl4U
lLwPrZqZcUwDR7JYG801EEI+IVlF6bBMWyM6gd/aypV3RGk4uhlIZ2sbgE0Nyw6e
WDQ8qFGXeHzNp77i+vhGapVbPxddHNLv7RTtkbXOoi+Gor5ABctxsIsDwPed/3sP
DmQZIZn2iHAYRdsJReCfwM28fPOCcTQL/ppHNLGppezjinhv19/iADIfNs4Qh/DN
oPHMsl0YWqVDLjVm7B6s
=mxA5
-----END PGP SIGNATURE-----

--envbJBWh7q8WU6mo--

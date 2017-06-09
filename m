From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 18:22:16 +0200
Message-ID: <20170609162216.GF31464@kwain>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170609082541.GC31464@kwain>
 <20170609132624.GC20756@lunn.ch>
 <20170609140922.GD31464@kwain>
 <20170609144936.GF20756@lunn.ch>
 <20170609145630.GE31464@kwain>
 <20170609150340.GH20756@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="eDB11BtaWSyaBkpc"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        jason@lakedaemon.net, gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:49673 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751629AbdFIQW2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 12:22:28 -0400
Content-Disposition: inline
In-Reply-To: <20170609150340.GH20756@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--eDB11BtaWSyaBkpc
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 09, 2017 at 05:03:40PM +0200, Andrew Lunn wrote:
> > There are two busses, one generating c22 transactions and one generating
> > c45 transactions. Each bus has its own MDC/MDIO pins.
>=20
> O.K. That is what i wanted to know. So we want two completely separate
> device tree bindings, busses registered with Linux, etc.
>=20
> Thanks for clarification.

So in the end I need one change in v3: to bind the xSMI usage to
marvell,xmdio and the SMI one to marvell,orion-mdio. (Plus the GENMASK
and offset comments).

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--eDB11BtaWSyaBkpc
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOss4AAoJEFxNi8it27zYMVcP/jOrOyau0YLIiGtemXn3D13G
ITrsJ8WoqlKm9hE4l78jSYNh9J73eCDPl64WFo5Euq9lROf7PT8Iu83NDKFVEWQD
3lclunoIOxVrqkjgyUxznJnf+DU1jDxlE3y0kHYJSSUTqjFPHjPXSHen2NuVKvOg
GmLzkxsGm2F9cWOMzh+SSFYWRaLablB0NB/w7nW5tkIAMgMNSJmydnt/yuIlMVeW
Xvkix8tPwQhRVW7i8i+0QDiU71g33R/AB7s/PhwlNVOvf3gaJqsaMh1Y8kIg9lS4
2YPcvxAQynn4aLi0Iy+T9RtT3XjswLt/DsTNyN5DIEv9OxcZFaIOAVQqVm7l7UTV
3NnSQFk0//+Jr+rvZE3YRgB0DMyTSLgasDGuKo1hJzihzTbgEzf+s4YvmXGPczH7
SCqqy8h6Qml1HwxoE+b1A7dvqFcjdOXaTkwGPW8WJCP6zjC3B8XFJ1dMGvd9z1o8
rKy+mAGYBLpSLZP8gIFU8pLA9DLhJZIaOh0z/lhajAKvvLh7up/nRjiQBrxQIbOX
ZKXdUG3wbnPySsvd20+QC+TSK174FSEWlF5//u8nTqwiURvW5rKaGp77kvZhPkwW
F9grIwEEQ9cHWxWgMtCvYuA0l5YwsJLJKJ+NTjxh3Lutw/7Da7WBhXc3zMRiWxve
mWQBu2oiXODasyzu3fE3
=soeW
-----END PGP SIGNATURE-----

--eDB11BtaWSyaBkpc--

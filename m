From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next v2 10/10] arm64: dts: marvell: mcbin: enable
 more networking ports
Date: Wed, 23 Aug 2017 10:11:12 +0200
Message-ID: <20170823081112.GC5202@kwain>
References: <20170822170830.32413-1-antoine.tenart@free-electrons.com>
 <20170822170830.32413-11-antoine.tenart@free-electrons.com>
 <20170823072842.ibk6gqtswhamvppy@sapphire.tkos.co.il>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="c3bfwLpm8qysLVxt"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
        linux@armlinux.org.uk, nadavh@marvell.com, stefanc@marvell.com,
        mw@semihalf.com, linux-arm-kernel@lists.infradead.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:56710 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753570AbdHWILY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:11:24 -0400
Content-Disposition: inline
In-Reply-To: <20170823072842.ibk6gqtswhamvppy@sapphire.tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--c3bfwLpm8qysLVxt
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Baruch,

On Wed, Aug 23, 2017 at 10:28:42AM +0300, Baruch Siach wrote:
> On Tue, Aug 22, 2017 at 07:08:30PM +0200, Antoine Tenart wrote:
> > This patch enables the two GE/SFP ports. They are configured in 10GKR
> > mode by default. To do this the cpm_xdmio is enabled as well, and two
> > phy descriptions are added.
> >=20
> > Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> > Tested-by: Marcin Wojtas <mw@semihalf.com>
> > ---
> >  arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts | 30 +++++++++++++++=
++++++++
> >  1 file changed, 30 insertions(+)
> >=20
> > diff --git a/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts b/arch/a=
rm64/boot/dts/marvell/armada-8040-mcbin.dts
> > index abd39d1c1739..6cb4b000e1ac 100644
> > --- a/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts
> > +++ b/arch/arm64/boot/dts/marvell/armada-8040-mcbin.dts
> > @@ -127,6 +127,30 @@
> >  	};
> >  };
> > =20
> > +&cpm_xmdio {
> > +	status =3D "okay";
> > +
> > +	phy0: ethernet-phy@0 {
> > +		compatible =3D "ethernet-phy-ieee802.3-c45";
> > +		reg =3D <0>;
> > +	};
> > +
> > +	phy1: ethernet-phy@1 {
>=20
> Should be named 'ethernet-phy@8' to match the 'reg' property.

That's right.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--c3bfwLpm8qysLVxt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmdOKAACgkQXE2LyK3b
vNgIzA/8CKEAWBHcpgSfDRhBZx55K1ER0geltQ2do4H/eK7GftZ6YqCuUG6K5mLu
VT5T1rPgHzOqgKZvwM4wwoG0J+iFG8EwbRlnjtM18cPAKgYxCxkK9cwSXe2KNmTT
cMnwUAOO1e4HKN26iwdZCfgUieU41mv1AKoqejKdO9xpENywXUUo/e/Y70WdW/Dl
J5PYiWqQQqrM3cp65xrv+gd6sUZ19g+ZFQc/xOAmtGe6kAELY3ArGNXnJcWJEFPn
l/P1IIVhEOgIlcmwFCfqp1o2IbE7yFG2Nj6FBOk8XjP5XTzxYWvCcXi1nYShLKbw
0ZnPLiyCyFrlJBqHpCGSsEODn9q4OEki6OWbj7JdI8aNGlU3wp/DUJDa4YYiW1gN
g+/0eS11x7uyY5ehNVkh9FUMl04RctgYrEVLzb+5TZTaj8rlOYSjzL/jcyLZ7WfJ
jQGJO5SNn23PMZ7c23NdX9Gok8TNXACq4Sj2L+schw3GvcSYgnxcmlIfbq+dwB0d
8LgDHCY5D8KxG8LKCYkjL/qddyN22cSRTot+gVzydWAWWy1xjgQSaW/rHSnM314m
nRugKXJZbNg9sDaIp/eBDmlKzSI+iRHx/W+qontPd8mMREBMGM9zDAgi7Kpd6oqp
CT7mYK3HEYf1O1KvHPKQLbifqcxrWftMB1Lkd8lscvDpXgqCjD4=
=WHbN
-----END PGP SIGNATURE-----

--c3bfwLpm8qysLVxt--

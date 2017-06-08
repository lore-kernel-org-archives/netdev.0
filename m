From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH 9/9] arm64: marvell: dts: add xmdio nodes for 7k/8k
Date: Thu, 8 Jun 2017 11:03:07 +0200
Message-ID: <20170608090307.GC12385@kwain>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-10-antoine.tenart@free-electrons.com>
 <20170608084515.GA12385@kwain>
 <8737barh96.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="7qSK/uQB79J36Y4o"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47817 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751672AbdFHJDT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:03:19 -0400
Content-Disposition: inline
In-Reply-To: <8737barh96.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7qSK/uQB79J36Y4o
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Gregory,

On Thu, Jun 08, 2017 at 10:55:01AM +0200, Gregory CLEMENT wrote:
>  On jeu., juin 08 2017, Antoine Tenart <antoine.tenart@free-electrons.com=
> wrote:
> > On Wed, Jun 07, 2017 at 10:38:10AM +0200, Antoine Tenart wrote:
> >> diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arc=
h/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> >> index 2a99ff8fca2a..594356243ddb 100644
> >> --- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> >> +++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> >> @@ -103,6 +103,13 @@
> >>  				clocks =3D <&cps_syscon0 1 9>, <&cps_syscon0 1 5>;
> >>  			};
> >> =20
> >> +			cps_xmdio: mdio@12a600 {
> >> +				#address-cells =3D <1>;
> >> +				#size-cells =3D <0>;
> >> +				compatible =3D "marvell,xmdio";
> >> +				reg =3D <0x12a600 0x10>;
> >> +			};
> >> +
> >
> > Russell pointed out on IRC the mdio/xmdio interfaces aren't wired to
> > anything on the mcbin. We could either disable these interfaces by
> > default, or add explicit disables in the mcbin device tree.
> >
> > What's your thoughts on this?
>=20
> I prefer that we disable it by default and only enable it on the boards
> using it.

OK. I'll add a disabled status property in this patch, and I'll make
another series to fix the existing mdio nodes.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--7qSK/uQB79J36Y4o
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZORLLAAoJEFxNi8it27zYowoQAI37BtANmXc8wNEFBADltheH
AkrcdabH6mxsIEH2let/iOWcd3rOPFG1SNukdEIeHXoCVDRd+L+JmvBaQlmU/xGq
XFhSR3rcyjGb44f5hyqBxAOE0vgMaysUQ9ub3EuaDxWTqWJJbKMUTNjQdHwNVktJ
J7sJaQ3JKTZ7vSy8kTq47BdfOEP3D3dZf0yRBB/5ETHD8VroQ/Z/LY/7MHrhPtxf
2TLqSwnQQK0eZEuPrrXKprXFEF+f20AE1vOqVLrVk/SUnw0zh07sEdD+id0kyq1c
nOMrJkUgmff6WDbe81HvKUNXQXxUvrEwBPV6y6C2YOasCxT7iwB1VugdAX4wy30K
kY3dqk1xB7StV3/Aa8PqijiQVeZ0ccJFFHP3U9mEZfSwdNO2x9oue1Wp2iLSq4Lm
ngR0cOPaXDx9QMYnrdcNTwfYoRKr0dPZkivBnSOyjrkwFxFa7q04yMKp4qIMYL1K
pCWuALte3V/NJ0qX6j77Z3UhmElj8eAF+BhWUqxMUUK+bPG9uPFg4guTu+UzqQRU
eeJJZq+IbJgeFuNRr72huT2FedWNLOceWV1mED8Ch3DZ6zaEjrgb0RbZ+oh9H/YX
AcPOcElXHrIwpYL1F27Vs3mpn1P0B1l9dpGv+f0LXSKB97BWkYc4GSlK+L00WaXw
mJTWPxIIMpHLhgQjKpdY
=3k9T
-----END PGP SIGNATURE-----

--7qSK/uQB79J36Y4o--

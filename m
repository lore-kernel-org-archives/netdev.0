From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH 9/9] arm64: marvell: dts: add xmdio nodes for 7k/8k
Date: Thu, 8 Jun 2017 10:51:27 +0200
Message-ID: <20170608085127.GB12385@kwain>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-10-antoine.tenart@free-electrons.com>
 <20170608084515.GA12385@kwain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="jq0ap7NbKX2Kqbes"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47442 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbdFHIvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 04:51:39 -0400
Content-Disposition: inline
In-Reply-To: <20170608084515.GA12385@kwain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jq0ap7NbKX2Kqbes
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08, 2017 at 10:45:15AM +0200, Antoine Tenart wrote:
> On Wed, Jun 07, 2017 at 10:38:10AM +0200, Antoine Tenart wrote:
> > diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch=
/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> > index 2a99ff8fca2a..594356243ddb 100644
> > --- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> > +++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> > @@ -103,6 +103,13 @@
> >  				clocks =3D <&cps_syscon0 1 9>, <&cps_syscon0 1 5>;
> >  			};
> > =20
> > +			cps_xmdio: mdio@12a600 {
> > +				#address-cells =3D <1>;
> > +				#size-cells =3D <0>;
> > +				compatible =3D "marvell,xmdio";
> > +				reg =3D <0x12a600 0x10>;
> > +			};
> > +
>=20
> Russell pointed out on IRC the mdio/xmdio interfaces aren't wired to
> anything on the mcbin.

The ones found in the cp110 slave *

Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--jq0ap7NbKX2Kqbes
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZORAPAAoJEFxNi8it27zYQGMP/RIHx7LZ2+QN3gB7X8+Sw0uP
HIqhxgDHVcgkjfclCrF7kL2viA+v+QPuzsZSKaFXikqgcfqzfuuFoxGVC5ZvpJ2j
s974lOpsXD248FzvKFNlqdJSZpfxMisaVzd+S3sKiwWTh+o0lLo1H6rGmGLEQ7A8
lOuasWQYy2O4BWYh0TeWTypSndy2yhOdyA1rOkzlNUanLvQc83MNDl2Jf0MDrsii
G8Gzu+GYgvk/qsx21ds1LPBMN7xcJMoQ/hlmi2XC9fEys5YdBEM4SwsDthlnwFLN
zC0LJM74UUqXbWgDbo9vy3ohCZfrURUSkXN+qSbtr4CHoRGqwBk1mNFAgGPLjbhX
lgyClHL/MtlpqTDGATXwEfcfB4acmV6mq0idpl48YHJg/UJcGM/HKXUVmEHLlmRB
kEDZxv1WNtvs1kp+w+vtAME4btsfev6tqRNow8l5cOjjWCmm3KZh01RxcrQEDNCc
kCZxkLptmYi8wpGjWGcFTtBURlETdzGIB+23Ee32gxfta9oLDFbmVCeF6ft8IS9j
PiwW/GDPrKVE/5E6QxqgUCccnBJKGImRQ3Eso5s5yGhh6F1gcunFRfxMIymRltpR
CbLKHzY4ma2TFd6+dBnKeTLwoj9lQdvcbTOR/2MBrwj7PTWD/Do8W2KGpBYzYO/q
XFpwiICFjLfJs02Ufnf5
=QH4w
-----END PGP SIGNATURE-----

--jq0ap7NbKX2Kqbes--

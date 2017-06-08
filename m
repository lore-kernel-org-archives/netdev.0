From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH 9/9] arm64: marvell: dts: add xmdio nodes for 7k/8k
Date: Thu, 8 Jun 2017 10:45:15 +0200
Message-ID: <20170608084515.GA12385@kwain>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-10-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="tKW2IUtsqtDRztdT"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47190 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751781AbdFHIpg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 04:45:36 -0400
Content-Disposition: inline
In-Reply-To: <20170607083810.30922-10-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Gregory,

On Wed, Jun 07, 2017 at 10:38:10AM +0200, Antoine Tenart wrote:
> diff --git a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi b/arch/a=
rm64/boot/dts/marvell/armada-cp110-slave.dtsi
> index 2a99ff8fca2a..594356243ddb 100644
> --- a/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> +++ b/arch/arm64/boot/dts/marvell/armada-cp110-slave.dtsi
> @@ -103,6 +103,13 @@
>  				clocks =3D <&cps_syscon0 1 9>, <&cps_syscon0 1 5>;
>  			};
> =20
> +			cps_xmdio: mdio@12a600 {
> +				#address-cells =3D <1>;
> +				#size-cells =3D <0>;
> +				compatible =3D "marvell,xmdio";
> +				reg =3D <0x12a600 0x10>;
> +			};
> +

Russell pointed out on IRC the mdio/xmdio interfaces aren't wired to
anything on the mcbin. We could either disable these interfaces by
default, or add explicit disables in the mcbin device tree.

What's your thoughts on this?

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--tKW2IUtsqtDRztdT
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOQ6YAAoJEFxNi8it27zYinkP/A/jRqOpEB7/Iml/hxnhMnY4
pDT6BhO6WsRCe2JSA3SvQVMkJkHUfjixT0HJF9EWA06qIOCO69rAYYXj9oO0CIuR
K3JKmD7RvMYYRjdc7z8xS2KqmRggEhaUI+pTacIWHCjY7fXHyrViEE85VsorD0q+
fOZi0sjC+kRWXB5dJPTkE5NLOygWJ0gCzglIoppHyIJCGnvt1DYXUEgpbJ39zxTW
4ElQPqUo41SDs70cVWZaSAMwS4VaEnIn6Aaqe5oVyJaK72PWS1PLqM+W8aSwSIG0
Fhj3zxI/6lHF6wwyS10QWBLt3htrQHlMWoqpcmLmS8RpB15Ss0TnYFi2O91qUKBe
QKLRUPZqzY3ifu+X5YMGzc+j35gDfYeBFUWrjpnnqoAv5tE3a95h9NSLwfRjGXJu
gcucDrc9OYddCXJ/TpgYawKvnhos6ni9EMxWxA7SWYlXvWWBhVwwI0FuJaQYryuo
aawmijI+LQmtsLXG77wQb8T5fl+TcFHdw5Sf706MjSDFh8IKhbNR+lU9F9N5BWsi
adpfapIR3wGS4OZLzeGi+yQFrGxVr0qoW+E8qTEjFOpIKldgpn6UFLxOlPJhQCai
bGqi8ispRf9R6OPkwyAqavQcpY9qR5iofdRg5ZgLkbm7Wudx+GWymSCQhZnLO114
RkaNefEpu0Fa5y2XkhuU
=dwTw
-----END PGP SIGNATURE-----

--tKW2IUtsqtDRztdT--

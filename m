From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v4 04/10] ARM: dts: sun8i-h3: Add dt node for the syscon
 control module
Date: Mon, 10 Oct 2016 14:31:51 +0200
Message-ID: <20161010123151.GI3462@lukather>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-5-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="pe+tqlI1iYzVj1X/"
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, f.fainelli@gmail.com,
        andrew@lunn.ch, netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475828757-926-5-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--pe+tqlI1iYzVj1X/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Fri, Oct 07, 2016 at 10:25:51AM +0200, Corentin Labbe wrote:
> This patch add the dt node for the syscon register present on the
> Allwinner H3.
>=20
> Only two register are present in this syscon and the only one useful is
> the one dedicated to EMAC clock.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  arch/arm/boot/dts/sun8i-h3.dtsi | 5 +++++
>  1 file changed, 5 insertions(+)
>=20
> diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-h3=
=2Edtsi
> index 8a95e36..1101d2f 100644
> --- a/arch/arm/boot/dts/sun8i-h3.dtsi
> +++ b/arch/arm/boot/dts/sun8i-h3.dtsi
> @@ -140,6 +140,11 @@
>  		#size-cells =3D <1>;
>  		ranges;
> =20
> +		syscon: syscon@01c00000 {
> +			compatible =3D "syscon";

It would be great to have a more specific compatible here in addition
to the syscon, like "allwinner,sun8i-h3-system-controller".

Thanks,
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--pe+tqlI1iYzVj1X/
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX+4o3AAoJEBx+YmzsjxAgz9oP/2KFw9BquDOGDOqvfpVmrfRp
OjCpu7LvwRfq0j83C6iKSptxtIkwFaxf3leTqmY5pRIM0Jj8kOxJl/wUddJ1nJla
mJLjq8SKXyDKNjAl8g2oMn5aub6gu4dlmTrSVRrUaPuYMPbuVG6Rbt3x4RIUGNTW
tSgGnROCy0JFu9/xHtwJwLQ61vqNV+A+G8Uoxe9pEzG6k1eNxQnN+4+CYCmNLkwg
RB5904Q8Ow4mqtsXqUKUxcyAxhu3CatY0ipqNNibJhK6gwmocFButr5t8KZsOdoj
Aee24YphNZQXvZ5APwpmVFrBkGS49cRgay/BvafxCXYroWY1LHmVdlIm8PQU1/bQ
F8Nv6aZyA0NREsacegIEQFLPr/78jlxQYXfHXPPPTIuNvGw7dUs/hzLLEaUl4aEU
64ZQkXWM9WDPwnFeTVOAYuieN0O1zIX2ck9sGQozP5ObJUZYCNegt0kOMbBp5Jwi
voRu1MS3OtEPKFeektIqZmAUAotpucFQQu5K9PWCHFkcxYdpL+s56+dGCLBbDkQO
g5TGvE2Mj6uWlnM2ZzwN/IdtDOW6iiXYOYvH80eQ807bAA4+xzhr2f+CeUW9y6an
JmlI95S+uWy96wNZ89+reYQs/lr8aQ4AlkfSSf3o24J4NetyWKH8ZPrcTiydJ5MB
hMgS71JrMv04YQqMeJZh
=I5UJ
-----END PGP SIGNATURE-----

--pe+tqlI1iYzVj1X/--

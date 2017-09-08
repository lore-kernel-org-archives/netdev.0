From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v5 01/10] arm64: dts: allwinner: Restore EMAC changes
Date: Fri, 8 Sep 2017 09:19:54 +0200
Message-ID: <20170908071954.j2bhtw4wqa27fald@flea.lan>
References: <20170908071156.5115-1-clabbe.montjoie@gmail.com>
 <20170908071156.5115-2-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="tsk3vhysft3ppq3p"
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170908071156.5115-2-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tsk3vhysft3ppq3p
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 08, 2017 at 09:11:47AM +0200, Corentin Labbe wrote:
> diff --git a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts b/ar=
ch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> index 1c2387bd5df6..968908761194 100644
> --- a/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> +++ b/arch/arm64/boot/dts/allwinner/sun50i-h5-nanopi-neo2.dts
> @@ -50,6 +50,7 @@
>  	compatible =3D "friendlyarm,nanopi-neo2", "allwinner,sun50i-h5";
> =20
>  	aliases {
> +		ethernet0 =3D &emac;
>  		serial0 =3D &uart0;
>  	};
> =20
> @@ -108,6 +109,22 @@
>  	status =3D "okay";
>  };
> =20
> +&emac {
> +	pinctrl-names =3D "default";
> +	pinctrl-0 =3D <&emac_rgmii_pins>;
> +	phy-supply =3D <&reg_gmac_3v3>;
> +	phy-handle =3D <&ext_rgmii_phy>;
> +	phy-mode =3D "rgmii";
> +	status =3D "okay";
> +};
> +
> +&mdio {
> +	ext_rgmii_phy: ethernet-phy@7 {
> +		compatible =3D "ethernet-phy-ieee802.3-c22";
> +		reg =3D <7>;
> +	};
> +};
> +

This won't compile, you don't have that node in the H5 DTSI.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--tsk3vhysft3ppq3p
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZskSaAAoJEBx+YmzsjxAgxo0QAKk+jdym7tDAG/oM5Z2j+8c8
LETOPI44nXa/mrMKVzGhwyY1U6Zv6Tid2TE+2ItvUesz4P6ItkzLukB7XO8Y6O3p
aXjlCgPIEfR5GT1xz/aud2Y+RVq88dWaTc5BFbnLFq/v64nvwmMj/vG3dgsvDz/C
niVk/c8jXcygUxHYMB45B89aEUqcE6/u8NqJ5daxzrnCps24co7aQP3JuQYprK7D
tQN8q2QCUSaVWfcn+x6aK6jtRXf2UJnNPyieHJ2Vk8rCiYBnvi7OkPalPHssTnNM
mvBssbmOLYsUp+a79qi9XcjmAB/dVeZi3xeIdOoxpltUcMXlBeEudn9ANsxV9IT4
xCYMZPkaddnllpsZYAeoYooMAkOAxeAg9r9ChXfnMHpptRmES0C19wVDjc/1iAw/
pYIlvzur0CTU4k6IAdf4jEAKf5jNPwXWzVERmmHVXtaS+gd51yPZBUvVPSxwbCcC
V0xX439blrtXiy8MseX2YWA9KAFKqdA2ZbsQiFl6obmQ1JbNhux1OYkCrgt5gcJt
E48y1t4SMzUDTqjJAdJWT+gWKxxJ+TOa4Ytj5IAfxL44l7S3WUlZagHtH5oR0AsH
zRNtT52TxC5Mlx3UVhJ0qLCxU31cKE6e+VHIMR7Y8ZIWmX0H1ma/xOkieAp7zJJd
lhFAvzAWDodj4hIsw9KG
=EK9t
-----END PGP SIGNATURE-----

--tsk3vhysft3ppq3p--

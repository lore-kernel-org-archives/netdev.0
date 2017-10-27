From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v9 04/10] arm: dts: sunxi: h3/h5: represent the mdio
 switch used by sun8i-h3-emac
Date: Fri, 27 Oct 2017 17:12:20 +0200
Message-ID: <20171027151220.m3vbtqd22bbupvpe@flea>
References: <20171024175714.15840-1-clabbe.montjoie@gmail.com>
 <20171024175714.15840-5-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="vll6ktdf4tacmmcr"
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, catalin.marinas@arm.com,
        will.deacon@arm.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171024175714.15840-5-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vll6ktdf4tacmmcr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

The prefix should be ARM, uppercase.

On Tue, Oct 24, 2017 at 07:57:08PM +0200, Corentin Labbe wrote:
> Since dwmac-sun8i could use either an integrated PHY or an external PHY
> (which could be at same MDIO address), we need to represent this selection
> by a MDIO switch.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> ---
>  arch/arm/boot/dts/sunxi-h3-h5.dtsi | 32 +++++++++++++++++++++++++++-----
>  1 file changed, 27 insertions(+), 5 deletions(-)
>=20
> diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi b/arch/arm/boot/dts/sunxi=
-h3-h5.dtsi
> index d762098fc589..0e97df490aba 100644
> --- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> +++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
> @@ -422,14 +422,36 @@
>  			#size-cells =3D <0>;
>  			status =3D "disabled";
> =20
> -			mdio: mdio {
> +			mdio0: mdio {
>  				#address-cells =3D <1>;
>  				#size-cells =3D <0>;
> -				int_mii_phy: ethernet-phy@1 {
> -					compatible =3D "ethernet-phy-ieee802.3-c22";
> +				compatible =3D "snps,dwmac-mdio";
> +			};
> +
> +			mdio-mux {
> +				compatible =3D "allwinner,sun8i-h3-mdio-mux";
> +				#address-cells =3D <1>;
> +				#size-cells =3D <0>;
> +				mdio-parent-bus =3D <&mdio0>;

And you should have a line here.

Thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--vll6ktdf4tacmmcr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJZ80zUAAoJEBx+YmzsjxAgdQcQAItjSjc3OAvv6swqDXdtIm8C
bolP27w3v8D0iHKi9DuHp0w0JWA++jo8BwK17GqNcIrLurlrPk3QevWgHY6CURtE
QaFGZJYEw/AYD9kI8KJMwy/Kl/bCAgFBIkvIHEVVN3opXNjpiCn7gdc13yt1zqPV
vTvxmUMZcw1LaYxwG7hePxYnZO5mhAD4AevXqj8liu2JYa0Mb6qZzHdOq7JG3aHf
5WiLlH5e9lpw8L27oMyyJ6gM9QXGSbkuHCFURtYLHfL+WWr1maKEX7TNCUa1whrB
FgO41Xhops8uIaPN8RhIeNFlegojmLlpMjwwKUyiTazUVHzMYDOo9nTuWeoK3Dpf
qrOllSqyAy9yLlQMOB5PTCt9qDRiqlSY/EvKBPieuIfvsjEc+ScYoHRGEZidNnKl
CfpZop9Gk78WavkJaVSJHtDKgS4xLbKDHY6owFo4+ynOnhvGR5Jyveb1rmyS71d/
Gaeksb+SUQ1ItGTewPbi8q8m4DGBaQp2NQjY5cf+NxDjrdlsrO/eddv0kNH8x9RZ
LaSHRp8dNh8ouX9ECITt6IUfnCF3h+e003ijevjJI71UOwtfDrpZ+A6OCrofT/VH
LD4olNJ/qBu5MoQISNL7riPxU5pnnP0xKhKISBjWPCve1BWf60TSNNSNfMMKEKlT
rLRMaufCDlFIqkZPKlQf
=ggNH
-----END PGP SIGNATURE-----

--vll6ktdf4tacmmcr--

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH v3 4/9] ARM: dts: sun8i-h3: Add dt node for the syscon
 control module
Date: Mon, 12 Sep 2016 09:28:12 +0200
Message-ID: <20160912072812.GB9449@lukather>
References: <1473425117-18645-1-git-send-email-clabbe.montjoie@gmail.com>
 <1473425117-18645-5-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="7iMSBzlTiPOCCT2k"
Cc: robh+dt@kernel.org, mark.rutland@arm.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: Corentin Labbe <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473425117-18645-5-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 09, 2016 at 02:45:12PM +0200, Corentin Labbe wrote:
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
> index fdf9fdb..a39da6f 100644
> --- a/arch/arm/boot/dts/sun8i-h3.dtsi
> +++ b/arch/arm/boot/dts/sun8i-h3.dtsi
> @@ -140,6 +140,11 @@
>  		#size-cells =3D <1>;
>  		ranges;
> =20
> +		syscon: syscon@01c00000 {
> +			compatible =3D "syscon";

Having our compatible would be nice here. syscon doesn't mean anything
by itself.

> +			reg =3D <0x01c00000 0x34>;

And the size of our system controller is 0x1000

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--7iMSBzlTiPOCCT2k
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX1lkMAAoJEBx+YmzsjxAgrnkP+gOhQmUYJecYTQWoGBfxsRzY
5EvtXucs5Br9jpI18SxrWuVZ4iZzXEtZ089++W7Be/6lN6uY90LS4belQtkgUhKU
ZsAFgJnH8jsRLs2C3MmnCvoRRcbrGSccFHKSWZfhERU3b8iOTw2XG2uAzPONyEJo
2ZsqHvYLmvFfneILi1bib1m3aqwwiRRCSiCUOZ0rmvnlYd3Ra8xoC4kq4tDK3v3B
Yl5YyB9n/gcnJWOiiYHg64xyINmY3toOcJmhTEcAk2hurT8oRhLHybaRaEn8qHHR
f3k7wMM3rHJ5i0RrtNTdeyk8OypCXiGbwCqXF3YExUo30FRwtfQcQY5SWllrAHPq
dUiJYa/lNBUFCQz1xAQsM+jPc9/9ZYS32Ntd+J4SU4ekfdpp6AHVj5+CGiz7wD0/
GDIBndAa2nqdbF9L2VjvaXpq5lFUy5ZGUxYyoU5zI58BejHrUSqxmqyXXMBQ3yxM
NAByZCOx0kvDk+6hghOgmwFHx8y74ROyAu/JU8hBWurOpzE3DWmLPLJXPkNquF+m
xuf//Efbbr/sNAuN7SkNcfepiIwA3iqbEnHNzrQYy4nl1Cg5redYAnL2ZwuWiaAU
VWACkTbHU+aku2+gnLfdFtZsOtqVcE6GoYH+MKje1T46UEDHOnhJ8hSMPxMzADdP
ZYNhX+zkQAr4g6o7yFHj
=9gWZ
-----END PGP SIGNATURE-----

--7iMSBzlTiPOCCT2k--

From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v4 13/18] arm64: allwinner: sun50i-a64: add dwmac-sun8i
 Ethernet driver
Date: Wed, 12 Apr 2017 14:41:53 +0200
Message-ID: <20170412124153.q6zvdvqkroizaxgb@lukather>
References: <20170412111400.2296-1-clabbe.montjoie@gmail.com>
 <20170412111400.2296-14-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="vggbggij6e3f5b5f"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170412111400.2296-14-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--vggbggij6e3f5b5f
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 12, 2017 at 01:13:55PM +0200, Corentin Labbe wrote:
> The dwmac-sun8i is an Ethernet MAC that supports 10/100/1000 Mbit
> connections. It is very similar to the device found in the Allwinner
> H3, but lacks the internal 100 Mbit PHY and its associated control
> bits.
> This adds the necessary bits to the Allwinner A64 SoC .dtsi, but keeps
> it disabled at this level.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi | 37 +++++++++++++++++++++=
++++++
>  1 file changed, 37 insertions(+)
>=20
> diff --git a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi b/arch/arm64/b=
oot/dts/allwinner/sun50i-a64.dtsi
> index 0b0f4ab..2569827 100644
> --- a/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
> +++ b/arch/arm64/boot/dts/allwinner/sun50i-a64.dtsi
> @@ -287,6 +287,23 @@
>  				bias-pull-up;
>  			};
> =20
> +			rmii_pins: rmii_pins {
> +				pins =3D "PD10", "PD11", "PD13", "PD14",
> +						"PD17", "PD18", "PD19", "PD20",
> +						"PD22", "PD23";

Please align the wrapped lines on the first pin.

> +				function =3D "emac";
> +				drive-strength =3D <40>;

Do you actually need that for all the boards, or only a few of them?

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--vggbggij6e3f5b5f
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJY7iCRAAoJEBx+YmzsjxAgMBgP/2ZVzIHhX/NflpKuJijgewLb
ukRjBSwO9fsYjYAt+FmR8y3JuX6jtoTx7UagPJ/rH5z01Vq7Vf1mAlk47koHP6HD
HmhhB/LpG0l7VvpH30j/bIOgWb8BMkjgebXmE7iWyz0khWkkv8jnNRk3vcAGeG8p
jYVrjgIV1Z/DVNqPzU0IW1wAhwmRjvGEewyiZU/Iesie9Ij3IX8NHMFjnbEUid/P
Tuv6UluInBm1jumxY3fOFGFIvdL7M9eocMRT2YNOjB+n0MIBWyt42iKAN6Xd2uJC
sg0WToVdHm5UHa12qlO3JzXPgBtfz5/MKyIU9HcspZQlMcqDlBUN5IVE8jDOkz2R
nz3M2gmfeIOyxmwAhR2F34elrc93TD3/OsSRsdLZ6os1Tn34cdx6d+98P5Sms9sY
qW6r9wQsWx3g2D72MKTDhQYA/OimMBs8MuMe80++rN210PL9CH2d6Tlg+Cbvx/Rw
9mBfA4UqAzwHoESviKbn6g7L5DVdPNvTX4MdB+Msn0GwbQl7BmhB9zG22Fz1RK9l
24tl33RxFEcpxp9gKV1isS1hohlVYirn71vlvYstZly3SHGJEkmMzXXdjEn7cWau
sRExD4YQfi4IBCADfn1bw6QUmiXfv++bO3j4b2SI/Ko/jB0rstKJFE1i0Csx5IWe
pFCU0oPwCzd4VdzD/bT7
=tERr
-----END PGP SIGNATURE-----

--vggbggij6e3f5b5f--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

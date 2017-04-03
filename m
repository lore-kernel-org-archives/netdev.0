From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH v3 03/20] dt-bindings: net: Add DT bindings documentation
 for Allwinner dwmac-sun8i
Date: Mon, 3 Apr 2017 13:19:15 +0200
Message-ID: <20170403111915.4har25efln4c3qko@lukather>
References: <20170403091444.29876-1-clabbe.montjoie@gmail.com>
 <20170403091444.29876-4-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="s64l34bhq3ppmzcz"
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170403091444.29876-4-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--s64l34bhq3ppmzcz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 03, 2017 at 11:14:27AM +0200, Corentin Labbe wrote:
> This patch adds documentation for Device-Tree bindings for the
> Allwinner dwmac-sun8i driver.
>=20
> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> ---
>  .../devicetree/bindings/net/dwmac-sun8i.txt        | 77 ++++++++++++++++=
++++++
>  1 file changed, 77 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/dwmac-sun8i.txt
>=20
> diff --git a/Documentation/devicetree/bindings/net/dwmac-sun8i.txt b/Docu=
mentation/devicetree/bindings/net/dwmac-sun8i.txt
> new file mode 100644
> index 0000000..f01ef17
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dwmac-sun8i.txt
> @@ -0,0 +1,77 @@
> +* Allwinner sun8i GMAC ethernet controller
> +
> +This device is a platform glue layer for stmmac.
> +Please see stmmac.txt for the other unchanged properties.
> +
> +Required properties:
> +- compatible: should be one of the following string:
> +		"allwinner,sun8i-a83t-emac"
> +		"allwinner,sun8i-h3-emac"
> +		"allwinner,sun50i-a64-emac"
> +- reg: address and length of the register for the device.
> +- interrupts: interrupt for the device
> +- interrupt-names: should be "macirq"
> +- clocks: A phandle to the reference clock for this device
> +- clock-names: should be "stmmaceth"
> +- resets: A phandle to the reset control for this device
> +- reset-names: should be "stmmaceth"
> +- phy-mode: See ethernet.txt
> +- phy-handle: See ethernet.txt
> +- #address-cells: shall be 1
> +- #size-cells: shall be 0
> +- syscon: A phandle to the syscon of the SoC with one of the following
> + compatible string:
> +  - allwinner,sun8i-h3-system-controller
> +  - allwinner,sun8i-a64-system-controller
> +  - allwinner,sun8i-a83t-system-controller

I'm not sure you need to document those compatibles here.

> +Optional properties:
> +- allwinner,tx-delay: TX clock delay chain value. Range value is 0-0x07.=
 Default is 0)
> +- allwinner,rx-delay: RX clock delay chain value. Range value is 0-0x1F.=
 Default is 0)
> +Both delay properties are in 0.1ns step.

allwinner,tx-delay-ps and allwinner,rx-delay-ps, with the value in
picoseconds?

Looks good otherwise, thanks!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--s64l34bhq3ppmzcz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJY4i+vAAoJEBx+YmzsjxAgcKwQAMLSjkaoW3EnmVgeld/2VKZT
ANA6BmRP8CbSgK43W7YOngw+daZFS7/AMmPZg0MFSZrxjTBUUe3KbOph2FiJruZu
YJK3hEajCbZdtVmrJzFOv3OtCQHXUJ69zsaqF0HxD9TQmYvlF9uZH2Ga4cWxbtoo
+RQGzhgWkqBaZiF3mtnPjqFUyZXAV/7bPsfQ/oOW+ieT78kzFvigrn8OIH40uog+
drW5+3ZhbFDsfdtC9bi9Ydzd/O4GbVMzjZhIpaOPFnm8L4gfctqDeFLFS6iuO3O9
lelwTohstIH6ZhwVbeQuWdAOqkmg4VmlwmuhQb+vd6VKV99z99S1j03c0eihA1lD
FH155zm7ET8rYCX8OBY+yEqL9x7tNbDRsg7NbvJvKFDgSCUDYnKn58+DRZyyMLz1
jdTkSP1Sk4V3YT4BlcHnCjZVEWppvu7mluUWO1idu/wReMMA65HEnmCxNiKIdYUH
x5rXXwmqloqU9fKR9kCysAkZA630DF7xfw7p8KOZBuMAzcCGfDijfGojyOIVaxnE
QdgFkR2/fwKQNMsYDlodgg4hynvNj17KKlOuA/eAuL41CdUn731Gap8z5WAIRcnL
ZR23Ib/p+b6q7eXbweaVB/1hstDlsG3JXHSUcsHyJSLzyw13KR5V1MprMOzuKX9V
6S3Q732VFCVnsgUUf+2U
=W49h
-----END PGP SIGNATURE-----

--s64l34bhq3ppmzcz--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

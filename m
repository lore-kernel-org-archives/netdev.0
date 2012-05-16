From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 1/1] smsc95xx: add FLAG_POINTTOPOINT flag for driver_info
Date: Wed, 16 May 2012 12:38:40 +0100
Message-ID: <1337168320.4107.42.camel@deadeye>
References: <1337155302-26244-1-git-send-email-jgq516@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-AFG3JULNzdkpalkU0RyL"
Cc: steve.glendinning-sdUf+H5yV5I@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jgq516-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1337155302-26244-1-git-send-email-jgq516-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-AFG3JULNzdkpalkU0RyL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-05-16 at 16:01 +0800, jgq516-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
> From: Xiao Jiang <jgq516-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>=20
> commit c26134 introduced FLAG_POINTTOPOINT flag for USB ethernet devices
> which possibly use "usb%d" names, add this flag to make sure pandaboard
> can mount nfs with smsc95xx NIC.

These are normal Ethernet interfaces, whereas FLAG_POINTTOPOINT is for
devices that use non-standard short physical links.

Ben.

> Signed-off-by: Xiao Jiang <jgq516-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/usb/smsc95xx.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index 94ae669..e158288 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1192,7 +1192,8 @@ static const struct driver_info smsc95xx_info =3D {
>  	.rx_fixup	=3D smsc95xx_rx_fixup,
>  	.tx_fixup	=3D smsc95xx_tx_fixup,
>  	.status		=3D smsc95xx_status,
> -	.flags		=3D FLAG_ETHER | FLAG_SEND_ZLP | FLAG_LINK_INTR,
> +	.flags		=3D FLAG_ETHER | FLAG_POINTTOPOINT | FLAG_SEND_ZLP |
> +			  FLAG_LINK_INTR,
>  };
> =20
>  static const struct usb_device_id products[] =3D {

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-AFG3JULNzdkpalkU0RyL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT7ORwOe/yOyVhhEJAQoAOw//VsfBM2flAdjrv1gG5g4ukGKA5ounHI8h
iP1PWtlXUQx6LO0gBjzYNJRpFVW6Vw5VS9A5sQpJKP5Q9aWqnA/Vkbte5uCM4Lms
XHklGbFo0sUsWKR74FkRR81b6k6HiAlRaH7uJkiBDGiZQcej5hNEWs7bY7aXzg19
x+8AtDS7Kpb8lYB6FpeGb31iYkp2TtZ9FfIwnpm49nc7+73g76oqEK1GMg2APXUV
U+Y90nmxMy7esHsbyo3awwQazdinVoDGJAAijZBZRh03+JK+G3imddN3jNhRjEyG
Mv5lppYuIUJzOxD+CH0nj0JIXjYrThG7d3mSpH36zGDQKNpC0/Lna2Jp6op6+9LU
9Wt7aqaUX03BB+T5yfYxuFxpV56fuX1+H8CERgxNDfDVIP5Ap3ftAnb1ka6gNt2M
Fs+V0KpCm/wOm6LAuyLIPgzlJls6X36zINxR78wOLFR8LwEN7XQgNou57yWr6sGE
lNU65ETVDBI0IO5gwTiuVvxeFMy7TsIoF6isb7pNp7VMEp86ful8fFYeQCBd3j0L
GTvLz+CfA9mxcDuF9yVMmmR+JlGmNXwqeAN9pHyt6FJsP2cMzLpYfjj/V6ND+ndV
hcsBx5c9eSdO7rjRufIu70IPoBh8KgH4cpwnO1zIUNq+IVsZkULYunT8F751bPeC
RiHYuydiwTo=
=vUZg
-----END PGP SIGNATURE-----

--=-AFG3JULNzdkpalkU0RyL--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

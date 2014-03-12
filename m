From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [Patch 1/2] IB/mlx5: Implementation of PCI error handler
Date: Wed, 12 Mar 2014 18:34:12 +0000
Message-ID: <1394649252.23624.36.camel@deadeye.wl.decadent.org.uk>
References: <20140312034219.637916521@linux.vnet.ibm.com>
	 <20140312034512.065218504@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZAXA0Q2YwrYEMud+aMJK"
Cc: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140312034512.065218504-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-ZAXA0Q2YwrYEMud+aMJK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-11 at 22:42 -0500, clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org wrote:
[...]
> Index: b/include/linux/mlx5/driver.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- a/include/linux/mlx5/driver.h
> +++ b/include/linux/mlx5/driver.h
> @@ -51,10 +51,10 @@ enum {
>  };
> =20
>  enum {
> -       /* one minute for the sake of bringup. Generally, commands must a=
lways
> +       /* 10 msecs for the sake of bringup. Generally, commands must alw=
ays
>          * complete and we may need to increase this timeout value
>          */
> -       MLX5_CMD_TIMEOUT_MSEC   =3D 7200 * 1000,
> +       MLX5_CMD_TIMEOUT_MSEC   =3D 10 * 1000,

You seem to be changing the timeout from 2 hours (not one minute) to 10
seconds (not milliseconds).

Ben.

>         MLX5_CMD_WQ_MAX_NAME    =3D 32,
>  };
> =20
>=20

--=20
Ben Hutchings
Any sufficiently advanced bug is indistinguishable from a feature.

--=-ZAXA0Q2YwrYEMud+aMJK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyCopOe/yOyVhhEJAQrN3w/+JAggVZ5WL4Wc8knoOCwGfr99e1kkhgOq
EjiMU/4N1hIuROMp5l0VgGn1gqldJf+kYjSm3G4k7ICOssAbWPlEs1ZdTUukAMLj
qhMfZBUHZDZJUTSSIUljvfCdzwCggs53nImiDC5bRXyRQfiHH1DywyKSazpimjQK
SLGUoySJOMCIWv1zkih4YFcIDu5OW+zZ0jA4hNolC6YViReIzrpyISC/7mSSHGfB
NiV97QpIizk8JVrevIIywbZqh/ZcmmMjnJFcRYrg3pHqiGLjztWyc8UHaN1RXmti
+Xhk8SYPxIkQX4lsQgeGmOuQOQRZWFnzTSuCiaPlXPmpjf9Rpnq7Ej/7gRu1egMi
j8Ksq1RKuhxUuTKGJnZxZyU2bYrmTyKxynbG6V1bFtVQx4Ov3qX1mqKJkbHWa9YK
TKV8jrcUFA5ehwgV7f3sJlVsWxBhfQAa6PyYy5Q0nOXwL2qEw/FKEOuryxLwy2k5
MXdd8xmQ6tnRoK9dDICPgeHT4reuIjKLb3wH5uIJgzGvADMzU84UnRO13I6dNHIg
MsL+pCzgUJwEIyfQ/DHrzXuC2NcXzRI692TWxoCWFen6vYP+4PnvcYAs+RSrf4uM
rnpRb8D11r83sMHVYCusDo4WVNLajEGu0ylC8t7WstJfAbFNeJutqOec7a/Qj6VM
UVpJxSa2REw=
=Zg1I
-----END PGP SIGNATURE-----

--=-ZAXA0Q2YwrYEMud+aMJK--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

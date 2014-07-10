From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v7 04/33] net: set name assign type for names assigned
 using a static template
Date: Thu, 10 Jul 2014 10:52:29 +0200
Message-ID: <53BE544D.7000104@pengutronix.de>
References: <1404980258-30853-1-git-send-email-teg@jklm.no> <1404980258-30853-5-git-send-email-teg@jklm.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="p4lE36Uvm3pHr8rfKi22GgQoDG4pXl6vd"
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>
To: Tom Gundersen <teg@jklm.no>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404980258-30853-5-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--p4lE36Uvm3pHr8rfKi22GgQoDG4pXl6vd
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/10/2014 10:17 AM, Tom Gundersen wrote:
> This covers the trivial case:
>=20
> alloc_netdev(_, "foo%d", NET_NAME_ENUM, _);
>=20
> Signed-off-by: Tom Gundersen <teg@jklm.no>
> ---
>  drivers/net/can/dev.c                     | 2 +-

> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index 9f91fcb..2441348 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -565,7 +565,7 @@ struct net_device *alloc_candev(int sizeof_priv, un=
signed int echo_skb_max)
>  	else
>  		size =3D sizeof_priv;
> =20
> -	dev =3D alloc_netdev(size, "can%d", NET_NAME_UNKNOWN, can_setup);
> +	dev =3D alloc_netdev(size, "can%d", NET_NAME_ENUM, can_setup);
>  	if (!dev)
>  		return NULL;
> =20

For can/dev.c:

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--p4lE36Uvm3pHr8rfKi22GgQoDG4pXl6vd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlO+VE0ACgkQjTAFq1RaXHNcOgCeO4HisNnrIp0rzUB8DHz5XKFW
4hAAn1X+kNUOytY/MCzPMdcTTZ+NPVR+
=lr5p
-----END PGP SIGNATURE-----

--p4lE36Uvm3pHr8rfKi22GgQoDG4pXl6vd--

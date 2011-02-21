From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] CAN: add controller hardware name for Softing cards
Date: Mon, 21 Feb 2011 10:13:37 +0100
Message-ID: <4D622CC1.5050402@pengutronix.de>
References: <20110221090421.GF328@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig18A754E489E1EE1503F8F7ED"
Cc: netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34213 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab1BUJNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 04:13:42 -0500
In-Reply-To: <20110221090421.GF328@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig18A754E489E1EE1503F8F7ED
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 02/21/2011 10:04 AM, Kurt Van Dijck wrote:
> I just found that the controller hardware name is not set for the Softi=
ng
> driver. After this patch, "$ ip -d link show" looks nicer.
>=20
> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Marc

> ---
> diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/s=
ofting/softing_main.c
> index 5157e15..aeea9f9 100644
> --- a/drivers/net/can/softing/softing_main.c
> +++ b/drivers/net/can/softing/softing_main.c
> @@ -633,6 +633,7 @@ static const struct net_device_ops softing_netdev_o=
ps =3D {
>  };
> =20
>  static const struct can_bittiming_const softing_btr_const =3D {
> +	.name =3D "softing",
>  	.tseg1_min =3D 1,
>  	.tseg1_max =3D 16,
>  	.tseg2_min =3D 1,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig18A754E489E1EE1503F8F7ED
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk1iLMQACgkQjTAFq1RaXHN+nwCeLNPqnkOHvWCChei8pCs92Eyh
Qj4Anj2MCghPsj3bLYjHUsBJ86yFtbHG
=vkCJ
-----END PGP SIGNATURE-----

--------------enig18A754E489E1EE1503F8F7ED--

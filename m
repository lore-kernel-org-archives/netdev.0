From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 3/8] net: can: c_can: Add RAMINIT register information
 to driver data
Date: Thu, 13 Nov 2014 11:59:56 +0100
Message-ID: <54648F2C.2060007@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-4-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="9pl5f1EE5GT8gskDJLf4AgEa6FEJ9C6Jm"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51950 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932694AbaKMLA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 06:00:29 -0500
In-Reply-To: <1415371762-29885-4-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--9pl5f1EE5GT8gskDJLf4AgEa6FEJ9C6Jm
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 03:49 PM, Roger Quadros wrote:
> Some platforms (e.g. TI) need special RAMINIT register handling.
> Provide a way to store RAMINIT register description in driver data.
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>  drivers/net/can/c_can/c_can.h          | 6 ++++++
>  drivers/net/can/c_can/c_can_platform.c | 1 +
>  2 files changed, 7 insertions(+)
>=20
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_ca=
n.h
> index 26c975d..3c305a1 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -171,6 +171,12 @@ enum c_can_dev_id {
> =20
>  struct c_can_driver_data {
>  	enum c_can_dev_id id;
> +
> +	/* RAMINIT register description. Optional. */
> +	u8 num_can;		/* Number of CAN instances on the SoC */
> +	u8 *raminit_start_bits;	/* Array of START bit positions */
> +	u8 *raminit_done_bits;	/* Array of DONE bit positions */
> +	bool raminit_pulse;	/* If set, sets and clears START bit (pulse) */
>  };
> =20
>  /* c_can private data structure */
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index 1546c2b..20deb67 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -250,6 +250,7 @@ static int c_can_plat_probe(struct platform_device =
*pdev)
>  	}
> =20
>  	priv =3D netdev_priv(dev);
> +

Dropped this hunk while applying.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--9pl5f1EE5GT8gskDJLf4AgEa6FEJ9C6Jm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZI8sAAoJECte4hHFiupUsTIP/2o5V6D30laDDQFGvQEPlo9k
7mQwj0PDoc+Ss0y3D3bJSsNafHyvqYRFT6i4kXiroofHsJNlTFaPjZ0oJ1X+K8ID
UF8o2dm9oHr5jiJ2oE18gNkIACZQ07KNZqBj6DjJmgs2Am+zm+NN8+FnNA9VQ3P0
dgBv+9pYTr2pjT+4NPExunen93EDsf1DNHK+1qRCo0eY9Q1YTJqDwfICUf+Tw3Z2
8KnBHyioiXreOGArTTgAyVLgakoO5UFLUjtYhDZWKbeDFeFqFPhJujr4OOPSuSjc
Bcmh+xkv0KxCxonzV65HHAuWQ2Gi9W8k6KVYWByDCNRGn4CwpcTSzD1p0fekGrQf
pP1nPODqdvvuffvzNVF/SyJZuBK94fBn89ir7DyGu2xXE0WVzisRKVEtu31SVFNP
f9oRRe3Rg4QqmVm2+GZVgFrQ/AV7rf6gp68eRrOq8wcIBCQau6ZzdMMri4m9fuVk
nRUVS9Z4G5JVpoCwq3UCV9TAuQyGhWQQ2N3zYjJwclSamm+UQhwA0VFKLMhIRR26
2BO7VUa5KhW9zc07li1SDHfiyrMujocWSUfWF+YXUtpbiD4IFUHGruobq2xF/9DO
4CjEpCLMOzQYB95uSWa5J2TOzgMomVUM6Ia3+vhN65ZMB6DkcG0N1vpXRG99UYYa
v5FvBrlnJCtL4vbD6+3C
=sCMj
-----END PGP SIGNATURE-----

--9pl5f1EE5GT8gskDJLf4AgEa6FEJ9C6Jm--

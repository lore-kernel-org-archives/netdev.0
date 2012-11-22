From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v6] can: kvaser_usb: Add support for Kvaser CAN/USB devices
Date: Thu, 22 Nov 2012 12:01:29 +0100
Message-ID: <50AE0609.1030101@pengutronix.de>
References: <1343626352-24760-1-git-send-email-olivier@sobrie.be> <1353481873-3214-1-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAB31021B077780C55D49AB74"
Cc: Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Daniel Berglund <db@kvaser.com>
To: Olivier Sobrie <olivier@sobrie.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57892 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751919Ab2KVSo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 13:44:57 -0500
In-Reply-To: <1353481873-3214-1-git-send-email-olivier@sobrie.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAB31021B077780C55D49AB74
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/21/2012 08:11 AM, Olivier Sobrie wrote:
> This driver provides support for several Kvaser CAN/USB devices.
> Such kind of devices supports up to three CAN network interfaces.
>=20
> It has been tested with a Kvaser USB Leaf Light (one network interface)=

> connected to a pch_can interface.
> The firmware version of the Kvaser device was 2.5.205.
>=20
> List of Kvaser devices supported by the driver:
>   - Kvaser Leaf Light
>   - Kvaser Leaf Professional HS
>   - Kvaser Leaf SemiPro HS
>   - Kvaser Leaf Professional LS
>   - Kvaser Leaf Professional SWC
>   - Kvaser Leaf Professional LIN
>   - Kvaser Leaf SemiPro LS
>   - Kvaser Leaf SemiPro SWC
>   - Kvaser Memorator II HS/HS
>   - Kvaser USBcan Professional HS/HS
>   - Kvaser Leaf Light GI
>   - Kvaser Leaf Professional HS (OBD-II connector)
>   - Kvaser Memorator Professional HS/LS
>   - Kvaser Leaf Light "China"
>   - Kvaser BlackBird SemiPro
>   - Kvaser USBcan R
>=20
> Signed-off-by: Daniel Berglund <db@kvaser.com>
> Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
> ---

[...]
> +static struct usb_device_id kvaser_usb_table[] =3D {

this can be const

> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_DEVEL_PRODUCT_ID) },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_PRODUCT_ID) },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_SPRO_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_LS_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_SWC_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_LIN_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_SPRO_LS_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_SPRO_SWC_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMO2_DEVEL_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMO2_HSHS_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_UPRO_HSHS_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_GI_PRODUCT_ID) },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_PRO_OBDII_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS |
> +			       KVASER_HAS_SILENT_MODE },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MEMO2_HSLS_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_CH_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_BLACKBIRD_SPRO_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_OEM_MERCURY_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_OEM_LEAF_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ USB_DEVICE(KVASER_VENDOR_ID, USB_CAN_R_PRODUCT_ID),
> +		.driver_info =3D KVASER_HAS_TXRX_ERRORS },
> +	{ }
> +};
[...]

> +static struct can_bittiming_const kvaser_usb_bittiming_const =3D {

this, too.

> +	.name =3D "kvaser_usb",
> +	.tseg1_min =3D KVASER_USB_TSEG1_MIN,
> +	.tseg1_max =3D KVASER_USB_TSEG1_MAX,
> +	.tseg2_min =3D KVASER_USB_TSEG2_MIN,
> +	.tseg2_max =3D KVASER_USB_TSEG2_MAX,
> +	.sjw_max =3D KVASER_USB_SJW_MAX,
> +	.brp_min =3D KVASER_USB_BRP_MIN,
> +	.brp_max =3D KVASER_USB_BRP_MAX,
> +	.brp_inc =3D KVASER_USB_BRP_INC,
> +};

I'm adding the consts while applying the patch.

Thanks,
Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigAB31021B077780C55D49AB74
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iEYEARECAAYFAlCuBg4ACgkQjTAFq1RaXHN4ggCgjk+EsutCMWXjbrknr3C8EBRH
WYsAn3KQNk6T0ckjIVSvSzquKOVcedLJ
=iRgH
-----END PGP SIGNATURE-----

--------------enigAB31021B077780C55D49AB74--

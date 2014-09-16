From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: usb: peak_usb: pcan_usb_core.c:  Cleaning up
 missing null-terminate in conjunction with strncpy
Date: Tue, 16 Sep 2014 16:09:32 +0200
Message-ID: <5418449C.7060808@pengutronix.de>
References: <1410715898-15904-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="uAgvDBGiaJiASEu6KDPo4wcV8jQiumRKC"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"Christopher R. Baker" <cbaker@rec.ri.cmu.edu>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1410715898-15904-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--uAgvDBGiaJiASEu6KDPo4wcV8jQiumRKC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/14/2014 07:31 PM, Rickard Strandqvist wrote:
> Replacing strncpy with strlcpy to avoid strings that lacks null termina=
te.
>=20
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital=
=2Ese>
> ---
>  drivers/net/can/usb/peak_usb/pcan_usb_core.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net=
/can/usb/peak_usb/pcan_usb_core.c
> index 644e6ab..d4fe8ac 100644
> --- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
> @@ -830,7 +830,7 @@ static void peak_usb_disconnect(struct usb_interfac=
e *intf)
>  		char name[IFNAMSIZ];
> =20
>  		dev->state &=3D ~PCAN_USB_STATE_CONNECTED;
> -		strncpy(name, netdev->name, IFNAMSIZ);
> +		strlcpy(name, netdev->name, IFNAMSIZ);
> =20
>  		unregister_netdev(netdev);
>  		free_candev(netdev);
>=20

What about removing the dev_info(), the name array and the str?cpy()
completely?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--uAgvDBGiaJiASEu6KDPo4wcV8jQiumRKC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQYRJwACgkQjTAFq1RaXHNFVgCfTa+BDlMUpQkqqLbrm+yAxnKg
0xEAn0XC/whypEq/c1aDdTX0NPFJY/Vu
=yOFv
-----END PGP SIGNATURE-----

--uAgvDBGiaJiASEu6KDPo4wcV8jQiumRKC--

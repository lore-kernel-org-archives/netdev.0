From: Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>
Subject: Re: [PATCH 1/2] net-ath9k_htc: Delete an unnecessary variable
 initialisation in ath9k_hif_usb_rx_stream()
Date: Fri, 1 Jan 2016 20:14:46 +0100
Message-ID: <5686D026.6000706@rempel-privat.de>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5686C390.5060600@users.sourceforge.net>
 <5686C42A.5000405@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="8WhpjSiebErDkk2wTiJrdvjCVeaF7cdQR"
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5686C42A.5000405-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8WhpjSiebErDkk2wTiJrdvjCVeaF7cdQR
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 01.01.2016 um 19:23 schrieb SF Markus Elfring:
> From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> Date: Fri, 1 Jan 2016 19:00:53 +0100
>=20
> Omit explicit initialisation at the beginning for one local variable
> that is redefined before its first use.
>=20
> Signed-off-by: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> ---
>  drivers/net/wireless/ath/ath9k/hif_usb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wir=
eless/ath/ath9k/hif_usb.c
> index 165dd20..51bd61b 100644
> --- a/drivers/net/wireless/ath/ath9k/hif_usb.c
> +++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
> @@ -525,7 +525,7 @@ static void ath9k_hif_usb_rx_stream(struct hif_devi=
ce_usb *hif_dev,
>  				    struct sk_buff *skb)
>  {
>  	struct sk_buff *nskb, *skb_pool[MAX_PKT_NUM_IN_TRANSFER];
> -	int index =3D 0, i =3D 0, len =3D skb->len;
> +	int index =3D 0, i, len =3D skb->len;
>  	int rx_remain_len, rx_pkt_len;
>  	u16 pool_index =3D 0;
>  	u8 *ptr;
>=20


Reviewed-by: Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>

--=20
Regards,
Oleksij


--8WhpjSiebErDkk2wTiJrdvjCVeaF7cdQR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iF4EAREIAAYFAlaG0CYACgkQHwImuRkmbWmDhAD+KNPibYR3y8scvydLtCLRK6Im
gug4CSunNSk9VLB7NmsA/RdOCOMFBzf9KhnRFhdFDyP7RxRTyCDmKKiyjXmhgigV
=FDRM
-----END PGP SIGNATURE-----

--8WhpjSiebErDkk2wTiJrdvjCVeaF7cdQR--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

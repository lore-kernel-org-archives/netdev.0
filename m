From: Oleksij Rempel <fishor@gmx.net>
Subject: Re: [PATCH] ath9k_htc: advertise support for TDLS
Date: Tue, 19 Aug 2014 10:25:25 +0200
Message-ID: <53F309F5.4020101@gmx.net>
References: <1408319614-16041-1-git-send-email-csaba.kiraly@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Vbg41GBcj4rdHRSuWupmxIKlC7caP22Jc"
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org
To: Csaba Kiraly <csaba.kiraly@gmail.com>, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:61872 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750767AbaHSI0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Aug 2014 04:26:08 -0400
In-Reply-To: <1408319614-16041-1-git-send-email-csaba.kiraly@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Vbg41GBcj4rdHRSuWupmxIKlC7caP22Jc
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Am 18.08.2014 um 01:53 schrieb Csaba Kiraly:
> Based on a quick test with AR9271, TDLS seems to be working fine.
>=20
> Tests were done with 2 Atheros AR9271 based devices with firmware
> 1.3 (sha1 8d49f928aa40ac53c729189bff1333cd373a7fb5), associated
> with a WAP54G access point.

please, don't use firmware 1.3. Use git source, or you can get
precompiled version here:
https://github.com/olerem/ath9k-htc-firmware-blob

> TDLS worked fine both in WPA2 mode and
> without encryption. Stations maintained ping flood traffic between
> each other and towards the AP without significant losses.
>=20
> Not tested with AR7010.

Seems ok for me. How can i reproduce testing environment?

> TDLS was enabled in earlier patches the same way for other
> Atheros drivers:
> ath9k (fd6562344dea2b8b2a5d644cf971f4e56004500a),
> and carl9170 (d1f3de71a584a82ee4e84505fce9acccf40215ff).
>=20
> Signed-off-by: Csaba Kiraly <csaba.kiraly@gmail.com>
> ---
>  drivers/net/wireless/ath/ath9k/htc_drv_init.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/ne=
t/wireless/ath/ath9k/htc_drv_init.c
> index 8a3bd5f..d779f4f 100644
> --- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
> +++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
> @@ -592,6 +592,8 @@ static void ath9k_set_hw_capab(struct ath9k_htc_pri=
v *priv,
>  	hw->wiphy->flags |=3D WIPHY_FLAG_IBSS_RSN |
>  			    WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL;
> =20
> +	hw->wiphy->flags |=3D WIPHY_FLAG_SUPPORTS_TDLS;
> +
>  	hw->queues =3D 4;
>  	hw->max_listen_interval =3D 1;
> =20
>=20



--Vbg41GBcj4rdHRSuWupmxIKlC7caP22Jc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iF4EAREIAAYFAlPzCfUACgkQHwImuRkmbWmzwgD/XMmk5nm0IP6OalpJTeAmsKWV
SyT4HjEZD1iiWQRiNA4A/2OKCog0ksro1Dv7VK93P44xoL2KfjdQHn6614vAoYmD
=S+Kv
-----END PGP SIGNATURE-----

--Vbg41GBcj4rdHRSuWupmxIKlC7caP22Jc--

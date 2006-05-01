From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] irda-usb: use NULL instead of 0
Date: Tue, 2 May 2006 00:19:20 +0200
Message-ID: <200605020019.25382.IvDoorn@gmail.com>
References: <20060501150807.b05fe450.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2336204.1L08bP45Ou";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.185]:35313 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932301AbWEAWSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 18:18:07 -0400
Received: by nproxy.gmail.com with SMTP id n29so2073427nfc
        for <netdev@vger.kernel.org>; Mon, 01 May 2006 15:18:06 -0700 (PDT)
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060501150807.b05fe450.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2336204.1L08bP45Ou
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 2 May 2006 00:08, Randy.Dunlap wrote:
> From: Randy Dunlap <rdunlap@xenotime.net>
>=20
> Use NULL instead of 0 for a null pointer value (sparse warning):
> drivers/net/irda/irda-usb.c:1781:30: warning: Using plain integer as NULL=
 pointer
>=20
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> ---
>  drivers/net/irda/irda-usb.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
>=20
> --- linux-2617-rc3.orig/drivers/net/irda/irda-usb.c
> +++ linux-2617-rc3/drivers/net/irda/irda-usb.c
> @@ -1778,7 +1778,7 @@ static int irda_usb_probe(struct usb_int
> =20
>  	if (self->needspatch) {
>  		ret =3D usb_control_msg (self->usbdev, usb_sndctrlpipe (self->usbdev, =
0),
> -				       0x02, 0x40, 0, 0, 0, 0, msecs_to_jiffies(500));
> +				       0x02, 0x40, 0, 0, NULL, 0, msecs_to_jiffies(500));

I could be mistaken, but wasn't the usb_control_msg timeout type changed in=
 kernel 2.6.12?
The timeout value is no longer in jiffies but in msecs.

>  		if (ret < 0) {
>  			IRDA_DEBUG (0, "usb_control_msg failed %d\n", ret);
>  			goto err_out_3;

IvD

--nextPart2336204.1L08bP45Ou
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEVoltaqndE37Em0gRAuLoAJ0XqLuyVCbLVtZ7RBmbAnyfC60nHQCfe4XF
qCtrH03re7zDTsx0DUJCO58=
=mnpQ
-----END PGP SIGNATURE-----

--nextPart2336204.1L08bP45Ou--

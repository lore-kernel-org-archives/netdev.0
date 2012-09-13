From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH 9/9] drivers/isdn/gigaset/common.c: Remove useless kfree
Date: Thu, 13 Sep 2012 11:52:27 +0200
Message-ID: <5051ACDB.5030407@imap.cc>
References: <1347462407-13499-9-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig82CCBC75DD5C689D2297D630"
Cc: Hansjoerg Lipp <hjlipp@web.de>, kernel-janitors@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347462407-13499-9-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig82CCBC75DD5C689D2297D630
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Am 12.09.2012 17:06, schrieb Peter Senna Tschudin:
> From: Peter Senna Tschudin <peter.senna@gmail.com>
>=20
> Remove useless kfree() and clean up code related to the removal.
>=20
> The semantic patch that finds this problem is as follows:
[...]
>=20
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Acked-by: Tilman Schmidt <tilman@imap.cc>

> ---
>  drivers/isdn/gigaset/common.c |    1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/commo=
n.c
> index aa41485..30a6b17 100644
> --- a/drivers/isdn/gigaset/common.c
> +++ b/drivers/isdn/gigaset/common.c
> @@ -1123,7 +1123,6 @@ struct gigaset_driver *gigaset_initdriver(unsigne=
d minor, unsigned minors,
>  	return drv;
> =20
>  error:
> -	kfree(drv->cs);
>  	kfree(drv);
>  	return NULL;
>  }

This is indeed vestigial code, left in when another error path
that needed it was removed. Though innocuous, it's better to
remove it.

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)




--------------enig82CCBC75DD5C689D2297D630
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAlBRrOcACgkQMdB4Whm86/ntSwCfT5hw2bM/EQH3o+ymlNaygg8j
VyEAnjBVSKhlpTSGCaEJ4rFqXEDnyRSI
=spk4
-----END PGP SIGNATURE-----

--------------enig82CCBC75DD5C689D2297D630--

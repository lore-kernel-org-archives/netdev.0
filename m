From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] ssb: sprom: replace strict_strtoul() with kstrtoul()
Date: Sat, 1 Jun 2013 11:10:55 +0200
Message-ID: <20130601111055.1f9fcf4c@milhouse>
References: <001601ce5e9a$93bc9fb0$bb35df10$@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/UOmTuny9zLZw4l++WuC5lxN"; protocol="application/pgp-signature"
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"'David S. Miller'" <davem@davemloft.net>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:39601 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754430Ab3FAJLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jun 2013 05:11:15 -0400
In-Reply-To: <001601ce5e9a$93bc9fb0$bb35df10$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/UOmTuny9zLZw4l++WuC5lxN
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 01 Jun 2013 16:35:23 +0900
Jingoo Han <jg1.han@samsung.com> wrote:

> The usage of strict_strtoul() is not preferred, because
> strict_strtoul() is obsolete. Thus, kstrtoul() should be
> used.

Looks good. John, can you apply, please?

>=20
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> ---
>  drivers/ssb/sprom.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/ssb/sprom.c b/drivers/ssb/sprom.c
> index a3b2364..e753fbe 100644
> --- a/drivers/ssb/sprom.c
> +++ b/drivers/ssb/sprom.c
> @@ -54,7 +54,7 @@ static int hex2sprom(u16 *sprom, const char *dump, size=
_t len,
>  	while (cnt < sprom_size_words) {
>  		memcpy(tmp, dump, 4);
>  		dump +=3D 4;
> -		err =3D strict_strtoul(tmp, 16, &parsed);
> +		err =3D kstrtoul(tmp, 16, &parsed);
>  		if (err)
>  			return err;
>  		sprom[cnt++] =3D swab16((u16)parsed);



--=20
Michael

--Sig_/UOmTuny9zLZw4l++WuC5lxN
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBAgAGBQJRqbqjAAoJEPUyvh2QjYsOJqAQAORQxz9QqXAD0MBo3rax0S3E
QWJp0LkwrGOf1vUCJbQL9yR0xrB97eTyYDcyycm14rx6KEpyaiwVFqNAXXuhWEBp
sQede8YzKSSEyb06gs0DkvbdJay2BJNbmFPyun+/+bvdkMaV0UuXwRGisRFRijqT
yXDpXkLXsxvwlR3fCq6FdT9ZenhrHbCTS2i+/OsgKGfx84Ch27uNl7KO5ORYtSLR
sSqaCkhnOWS2N0ZEgENcuWTRqJ8s/zKdY6miebkp3iiGAimiXQICcUgu1yZ5KLfX
/rQzZdurjbah4CzTOJrd86IA9/N3eB9ya5gt43lPYQCBSadU4AAwxIAnBoRIRmuf
LHopvoTVQXMuUNYJ2ulf3YKkntW3NGkvBULi3D/5vVGDZ4MKGDwvsBEcxK7q7H1k
+/MRsLA7TsE3RoU8BAelvLotqipBnnoU0vExBLdrk4AJZIiF3xxlFis182RnIy76
gl9DF62P9XsVmFevefEhVHRlMP0nYDkeHXeNVPWYqYrtq7oMsyBOfgupnbGpxz1H
d7fUhDy14o5Epbj3frnvDKwzOTR2cn4J7/lO/YmcjMjO/NBT85UIA+XUeVKKZ/l/
P0Q08zIm/ovJnLPCvhm1CuhNMHMrEfjLhlUFTrRrZZtspZdwHU1T7IVysFcT28q4
0u1t+bfpgGkoY2X79JiP
=sMcW
-----END PGP SIGNATURE-----

--Sig_/UOmTuny9zLZw4l++WuC5lxN--

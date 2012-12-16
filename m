From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] build: unbreak linkage of m_xt.so
Date: Sun, 16 Dec 2012 17:02:22 -0500
Message-ID: <201212161702.24623.vapier@gentoo.org>
References: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr> <1355617968-26138-1-git-send-email-jengelh@inai.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3527860.5BcSLlq8Zt";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, urykhy@gmail.com, shemonc@gmail.com,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1355617968-26138-1-git-send-email-jengelh@inai.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3527860.5BcSLlq8Zt
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Saturday 15 December 2012 19:32:48 Jan Engelhardt wrote:
> --- a/configure
> +++ b/configure
> @@ -4,7 +4,6 @@
>  INCLUDE=3D${1:-"$PWD/include"}
>=20
>  : ${PKG_CONFIG:=3Dpkg-config}
>  : ${CC=3Dgcc}
>=20
> -echo "PKG_CONFIG:=3D${PKG_CONFIG}" >>Config
>=20
>  # Make a temp directory in build tree.
>  TMPDIR=3D$(mktemp -d config.XXXXXX)
> @@ -224,6 +223,7 @@ rm -f $TMPDIR/ipsettest.c $TMPDIR/ipsettest
>  }
>=20
>  echo "# Generated config based on" $INCLUDE >Config
> +echo "PKG_CONFIG:=3D${PKG_CONFIG}" >>Config
>=20
>  echo "TC schedulers"

the use of un-indented shell functions makes the code read in a way it does=
n't=20
actually execute.  i'd suggest moving this logic into a function to match=20
existing style rather than simply moving the Config write.  i'll post a pat=
ch.
=2Dmike

--nextPart3527860.5BcSLlq8Zt
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQzkTwAAoJEEFjO5/oN/WBaUgQANArb8UIKUDwXSRAGiCLoaPF
4v7sB/yW+PxL5t7Wal0XqSM3qWs3Cz7iGm8zJVMnqtJy70GpeBnIHiIzDkWDEEgp
jpi2nxdKftqQO00rBEoLZdKY4QAtZu2eUvpjuJgHaIqQ2mz2TYUjpas5NUhidljW
F3r7aqzRDwuOJYnoZv9eq8uWblEPs9N8sR1Jtf9szk2VpbAvtKL8ZnzTzULAVFxZ
hgt1sXLXlu2EYL/c7oM7kswkf8pkVbNtvocEBnvw9X/oRSQdDq9JEkOzfuap7Dd9
i/dreyAqwnZnsww8WgAjRfSgpfV8p4B3jFPS7tiID2bxF11Y7RvnVfXS7P5MKO1e
l50ZnYk8xLlxyy0gVGjuWI7UGPP5HFBIZNmCeqr7S+wE2aLm5o2giaA+Nut8lySg
HYdAzZO9gTKwkYisV2vx7X5qY9aoJXSK33iGMa7dP1llEIZuylNT9vEBtPqwyt25
0poT4L49/99MXzY/HZGmNvKxkNeXwD8Y6h9icL8dngwBtbf0yMQS+Mm8uNJSl0On
EcCzGjk3ktCczgyNFe1aUyoGF//VYAhQrFRnGwsBK+1uGfqwn+rdfQc8nK4oEKpJ
F9Xtyg3qSYstu1+MqfnU6hfaqLcny2/yk0zsRIJWX6Tag8zypEhM/xfEg+ZAv9sP
GXyQtwyo6V/XIRa19oLT
=PWp4
-----END PGP SIGNATURE-----

--nextPart3527860.5BcSLlq8Zt--

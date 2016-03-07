From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 06/12] test-common.c: fix test_realloc(NULL,
 ...)
Date: Mon, 07 Mar 2016 16:07:32 +0000
Message-ID: <1457366852.15205.23.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-7-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uL4zuHcKXTQj9rg3dJnR"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43687 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752803AbcCGQHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:07:39 -0500
In-Reply-To: <1457138533-2417-7-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uL4zuHcKXTQj9rg3dJnR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> This fixes:
> =C2=A0 test-common.c: In function 'test_realloc':
> =C2=A0 test-common.c:109:8: error: 'block' may be used uninitialized in t=
his function [-Werror=3Dmaybe-uninitialized]
> =C2=A0=C2=A0=C2=A0=C2=A0block =3D realloc(block, sizeof(*block) + size);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0^
[...]

LGTM.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-uL4zuHcKXTQj9rg3dJnR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3adEAAoJEOe/yOyVhhEJUV4P/0+AJR5gPTjWxmAMZ2nOR1wn
2LsRNaV0Ve3djAcrCt1KSgWNLTiWwLrmjyxLUJGjs5sHK8IJp4sQ3dh/wpws+elR
L9wS3DBHNZfVtuEbNKxG3T0LTKqjCPaiwWHIOb/25C3vUaJJY9LjcT0yl+W26+CD
SuhHROMHy1+MN8HeCBRIzt8Gr6iGtt+5VIjKA4ojrXXtPd2q1tpuoGGbR58EHiUM
qyBxzntpz087njjWx5KX6sT7xjl3/8zjKi4nODP58+i1sogMNIviGpHB8NfNM1J1
uFl/UmutIJ6nphdJCz1424eQQ8K9Cb/yLKl0dutSj+CFt7wJWkFeKO6JJQgZSU2/
ZmV1vrtb7pQbSOqj36fCGTVNk+DlKdd/Oz6c3/kihyiib0XGwGSbuKPRZVkznNBg
RQmm7YkkiX8HwlnjgldiM4Z0UzQqVw5Sz2AEtT0akcdVJd1dC/YPecFQlUBjak17
Iu2+dtNuqXwje04P/wBo0ITpcOEAQzfXaLsPeBeB0Vw+sLIuR9+3XuAaailtm4ST
SR7FpohpGV055bqwlNOCa3nUvoW4kD4smGtZMn+7E34tgw+E93y+EjBGQv8KPA1l
MDQWc3pYdbD8oqdagz/lYmcuJVNuK13s4R6YmuLTdTxjKhNp48BdwxdB0Ag/5lvE
x9uv1nuyD9Z23QVxi0eP
=dDyg
-----END PGP SIGNATURE-----

--=-uL4zuHcKXTQj9rg3dJnR--

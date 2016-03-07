From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 10/12] internal.h: TRUE/FALSE macros
Date: Mon, 07 Mar 2016 16:12:16 +0000
Message-ID: <1457367136.15205.29.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-11-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MZZJdnKhf7a/g8tVFgO+"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43738 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbcCGQMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:12:23 -0500
In-Reply-To: <1457138533-2417-11-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MZZJdnKhf7a/g8tVFgO+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:

> From: David Decotigny <decot@googlers.com>
>=20
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
> =C2=A0internal.h | 8 ++++++++
> =C2=A01 file changed, 8 insertions(+)
>=20
> diff --git a/internal.h b/internal.h
> index 5df8124..7c44d0e 100644
> --- a/internal.h
> +++ b/internal.h
> @@ -42,6 +42,14 @@ typedef int32_t s32;
> =C2=A0#include "ethtool-copy.h"
> =C2=A0#include "net_tstamp-copy.h"
> =C2=A0
> +#ifndef TRUE
> +#=C2=A0=C2=A0define TRUE 1
> +#endif
> +
> +#ifndef FALSE
> +#=C2=A0=C2=A0define FALSE 0
> +#endif

I'd much prefer true and false as defined in <stdbool.h>.

Ben.

> =C2=A0#if __BYTE_ORDER =3D=3D __BIG_ENDIAN
> =C2=A0static inline u16 cpu_to_be16(u16 value)
> =C2=A0{
--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-MZZJdnKhf7a/g8tVFgO+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3ahgAAoJEOe/yOyVhhEJn9sQAJ/JWo4WfMo1WabwXE1V3v4y
lWmzqkePKTFtlf+tWsxGoTLpa0olD5lljHmaE6LAsPiEXLum6EZChFAfwkgORj8y
5vu6zBljMVJnwiufpj8wUPcsXwHMvNv7iVX9r3ZmG5dmrC/VKWqyllfp5pWiVSdd
OA9JtXsbd/qEzqRumsF9n3E5nhIOIySD8Vt9skXo/z2Knu7wKgttpfdF2lVA1qxh
h8seKXOpsoGI+mvPP7r2AO7hOTOWAF8g6UqXC013gBuVjKrGFVtr3xwTxzWdInYK
BkFif5uzg9QEx7KPe31By2jxVj8u6pKioJEpUYzrAe6ZnWcDv52GL46cG+OoupAU
qq9eDW9dGGXEhuEtsiigk5ebNdgRlMYI276/RZuwFleweQcv2/g+cRKYFX11p59V
fexMdYxEJQRAO5j8XvckjhqGp0g8tcn8AzvZIXTVCB5PwaX5xueW4FLUkv4liSX1
HDFzhBbzgsVnOzkYMaiNM48vIg2x9D3cQ+KfFAF/bIMm6pkj5KZcRi+2oIGBb8v8
vzohVgm/yJp2wDkZGuQDMbI3R3ktO/GYfEdj4MlJ7JZIiu3JtSPo0xJT3EWnh94c
Vc+FuyGEc1f4GsmgFaULaVwWiZoAzSarvmRWct1CsAt9Vzc5MrDv6uSLbz6vLLpO
fhN67Bha3TldK1KNy0Me
=8QTl
-----END PGP SIGNATURE-----

--=-MZZJdnKhf7a/g8tVFgO+--

From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v4 11/11] ethtool.c: support absence of v4
 sockets
Date: Sun, 13 Mar 2016 17:24:03 +0000
Message-ID: <1457889843.3331.36.camel@decadent.org.uk>
References: <1457719104-39188-1-git-send-email-ddecotig@gmail.com>
	 <1457719104-39188-12-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-kpRjA9raP9eKNEQ2rUJ8"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40966 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751290AbcCMRYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 13:24:23 -0400
In-Reply-To: <1457719104-39188-12-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kpRjA9raP9eKNEQ2rUJ8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-11 at 09:58 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
> =C2=A0ethtool.c | 3 +++
> =C2=A01 file changed, 3 insertions(+)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index 761252f..f9336e3 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -4615,6 +4615,9 @@ opt_found:
> =C2=A0		/* Open control socket. */
> =C2=A0		ctx.fd =3D socket(AF_INET, SOCK_DGRAM, 0);
> =C2=A0		if (ctx.fd < 0) {
> +			ctx.fd =3D socket(AF_UNIX, SOCK_DGRAM, 0);
> +		}

You still haven't answered whether this is a real problem on Linux.

Ben.

> +		if (ctx.fd < 0) {
> =C2=A0			perror("Cannot get control socket");
> =C2=A0			return 70;
> =C2=A0		}
--=20
Ben Hutchings
If at first you don't succeed, you're doing about average.
--=-kpRjA9raP9eKNEQ2rUJ8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW5aI0AAoJEOe/yOyVhhEJSIcP/3ekUakmKxYJGeUh9rtxlrAL
2T6Egz/koWatw23prynzH7M3A8irWzUpYVCKfTIcQbgQ+UNq2KklkFMCsamPFV1k
U0NoKbTVhxPItRpwuJvj3RvvAP2XY5rDi5K9CxdXHzJHF+TAVrwneQE4WAK9tOuX
v0P/UFNTkA+pp9bCAAEHm8AdFFCZnfQiaED7rBE2JkdCpJRo/Y2Z2X5Fy5VtOuGC
0azIR/9/2Dz0jjYwcS0CQ/aRj66IIzCfZR5P3NC1G1S6qbA+bREmZss8+fE56oBi
D3dCwk4FTDha0uI7AXEjAElQjNWd0ZFxBEj418iioddsLv8cy7Hl719/m9P8k16G
mhSAQFnqtRbe9nsTr+0qUoX5eFVALZuNCyNp/k2b55YrkOA8mCnY9c9Hy6iMgTSl
ncVTxQQOHtqEpiYvC/Kw9KJu/tjamG/DLX9xKappTAZGhAElN0jI6gkBAoH/SsFH
6qZcGCG5kR4ZhtlObtAHb7Gs6Vt17o3mMTp3+JnvA60TVC/O2jssBiu391Cqlp8p
jhI4SFRXZUBWyUyprfJJMlFVl2N7aE3KOdIAfvKvE04VeTwsrebCfEmmHHmBYlff
8+Te3wLxWAQSxnEvq1ShYUJtltOUxwIg4k3WUBbL/gCsu+pBr/WtU9QNIFujry0b
VsXBO1Cy609ttjB1wbfY
=K2Rx
-----END PGP SIGNATURE-----

--=-kpRjA9raP9eKNEQ2rUJ8--

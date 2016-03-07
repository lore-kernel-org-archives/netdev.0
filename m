From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 12/12] ethtool.c: use v6 socket when v4 is
 not available
Date: Mon, 07 Mar 2016 16:13:26 +0000
Message-ID: <1457367206.15205.30.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-13-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-lhWapLKQRVjBcpFLIKNa"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43750 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752803AbcCGQNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:13:33 -0500
In-Reply-To: <1457138533-2417-13-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-lhWapLKQRVjBcpFLIKNa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
> =C2=A0ethtool.c | 3 +++
> =C2=A01 file changed, 3 insertions(+)
>=20
> diff --git a/ethtool.c b/ethtool.c
> index e1acf09..4daf538 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -4618,6 +4618,9 @@ opt_found:
> =C2=A0		/* Open control socket. */
> =C2=A0		ctx.fd =3D socket(AF_INET, SOCK_DGRAM, 0);
> =C2=A0		if (ctx.fd < 0) {
> +			ctx.fd =3D socket(AF_INET6, SOCK_DGRAM, 0);
> +		}

Can this really happen on Linux? =C2=A0(AF_INET6 available but not AF_INET?=
)

Why not AF_UNIX? =C2=A0That's even more critical.

Ben.

> +		if (ctx.fd < 0) {
> =C2=A0			perror("Cannot get control socket");
> =C2=A0			return 70;
> =C2=A0		}
--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-lhWapLKQRVjBcpFLIKNa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3aimAAoJEOe/yOyVhhEJrZkQANDKO1ybnv0mRoy4nZQD44gj
W7pXuncYAYhKMgS6Dh7ueIUz/uMpFvic31SIrLaBRhTqGHQtLthtTBV4oNNddspD
lbvQkYjSfilkLWzMtd0QHFBj4X9fy48AZf9KoPH65NWWF1g+BJg6TlHiZrAAVNnj
A9CkJxs8RXcoNOv7Qc63qiGwWc3L7SSTBjnXP7RGfO12lLBR01v45U5eQPhAtQKl
8kMJjy2q3/A0FJyBIj488M8j+N50fNIc+4hmYITLpX4PdWu+2InFg1/DrQ9JczM6
W0Fd3mTfa8e+OWiZYnlspRm1qENNiWJGCSxmL+UW1tPJ2lMDOGlJr4167K3nv+nA
sQZeXtupyHF6QLPQLL0f+zmn3xgTh0UuPSgYDn0HLCwXdGBhF5xAiGY3K/xEy021
dmqBwNNZ72V3CUmLtw1nWG/bpgIVEyGicG06f1Fw08Rcjaz3YijG3rUtyjpUvh1N
EgtLEJtUHOQ3u/IXlamqrZXJ8WobUmk7dddPahB6jv22eQB5DK0Y36bSwlYgFbzT
JolBzfhmY1GKNWYbUn9ayKb5rC1meLeT3RjImuMpwfyCmikzV+0Xif9JF2HZ8OUJ
fR/kmm+4nvVXs4qjWW/IMX7Ji5vA0p6OFKqiGFZqhhl2iib0LvmnOyMkpAyF0jNf
odOZbcrobiMuAamflHc+
=yI5Q
-----END PGP SIGNATURE-----

--=-lhWapLKQRVjBcpFLIKNa--

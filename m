From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v4 1/1] Add timer to handle OOM situations
Date: Wed, 10 Aug 2016 13:24:18 +0100
Message-ID: <20160810122418.GE10461@stefanha-x1.localdomain>
References: <20160804140911.23453-1-ggarcia@deic.uab.cat>
 <20160804140911.23453-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="idY8LE8SD6/8DnRI"
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933743AbcHJSWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 14:22:36 -0400
Content-Disposition: inline
In-Reply-To: <20160804140911.23453-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--idY8LE8SD6/8DnRI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 04, 2016 at 04:09:11PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> Set up a rx timer to avoid packets being discarded when there is not=20
> available memory in the host.
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> ---
> v4:
>  * Fix style.
>=20
> v3:
>  * Avoid race condition when freeing timer.
>=20
> v2:
> * Use of ERR_PTR/PTR_ERR/IS_ERR
> * Timer cleaned on device release.
> * Do not process more packets on error.
>=20
>  drivers/vhost/vsock.c | 49 ++++++++++++++++++++++++++++++++++++++++-----=
----
>  1 file changed, 40 insertions(+), 9 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--idY8LE8SD6/8DnRI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXqxzyAAoJEJykq7OBq3PIh6AIAKl+DgQ4rqV1bqgzW77tqjpp
xKdNXWvJzyN6yGBVp0bRJUsGVT1mNLdX0zL16H93KMHZAnALF7haLVKMYBOZqb7T
efd2Lq9QnfetNVtrjOVZWidULCHYLV4DpXzbp6wtq+SOhPgwD/nLH40MZtnwx4mi
14DuQvvEO5/1Mur5Sr/g0W4VXmEM7EPEy+yuxGlcgZAdB4F8W3GBBhux5Kc6odaJ
Ijn0x3AhzjqXZ/2pZj2petMfQCCLqnJB8uRBvG8aJUSLtburYynl8sORJo/UUsC8
sDs3/G7xGp2JSb80IscVe3nO9kstCTfbyNff8Vt+DAHUKC5c33erNimgqRDy4Z0=
=oE/u
-----END PGP SIGNATURE-----

--idY8LE8SD6/8DnRI--

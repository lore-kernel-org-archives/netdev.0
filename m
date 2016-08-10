From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v2 1/1] Fix unbound rx buffer
Date: Wed, 10 Aug 2016 13:25:57 +0100
Message-ID: <20160810122557.GF10461@stefanha-x1.localdomain>
References: <20160804140957.23693-1-ggarcia@deic.uab.cat>
 <20160804140957.23693-2-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="GV0iVqYguTV4Q9ER"
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59116 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934207AbcHJSWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 14:22:13 -0400
Content-Disposition: inline
In-Reply-To: <20160804140957.23693-2-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--GV0iVqYguTV4Q9ER
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 04, 2016 at 04:09:57PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> Reset connection and close rx socket when the sender is ignoring our anno=
unced available buffer.
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> ---
> v2:
>  * Get vvs->rx_lock lock before checking if next packet is going to
>     overflow the rx buffer.
>=20
>  net/vmw_vsock/virtio_transport_common.c | 20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)

Acked-by: Stefan Hajnoczi <stefanha@redhat.com>

--GV0iVqYguTV4Q9ER
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXqx1VAAoJEJykq7OBq3PILCYIAKUyNDzVUe8C90N2CwN+WQKj
06I7hGeu9JaqWNsgtuBAhbi/+AX+6APMl5lvoe70kZcVN7RUfEzqf9cfC0YulXpC
Zysb0rqGHgXQk4C2yt5Ro6cFytc7F1619bQLRAZT8Jstwf3puSPvDyZAE0BUxWFn
7Omza7dJeXT+2EWDDHSprsFSbcKAGQ1zhCZW0u0nVfZWwlbEMMXRcgJo12lzCuLL
OPngPH83xuZtf1IloJHgHq9I8hXx/Ud7pdCVVfvkmteeCe8z7utNbAOapliWKwgO
hXcZuHFteYv2vJ0FnQJz1XxOBTHyKJt4V5L9LBcmXThFrbe50iKvatjTcIA7Iks=
=uFMQ
-----END PGP SIGNATURE-----

--GV0iVqYguTV4Q9ER--

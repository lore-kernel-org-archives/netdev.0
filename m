From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH 1/1] VSOCK: remove more space available check filling TX
 vq
Date: Wed, 10 Aug 2016 13:01:52 +0100
Message-ID: <20160810120152.GD10461@stefanha-x1.localdomain>
References: <20160805163420.10092-1-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TybLhxa8M7aNoW+V"
Cc: netdev@vger.kernel.org, mst@redhat.com
To: ggarcia@abra.uab.cat
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934217AbcHJShH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 14:37:07 -0400
Content-Disposition: inline
In-Reply-To: <20160805163420.10092-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TybLhxa8M7aNoW+V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 05, 2016 at 06:34:20PM +0200, ggarcia@abra.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>=20
> Remove unnecessary use of enable/disable callback notifications
> and the incorrect more space available check.
>=20
> The virtio_transport_tx_work handles when the TX virtqueue
> has more buffers available.
>=20
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> ---
>  net/vmw_vsock/virtio_transport.c | 9 ++-------
>  1 file changed, 2 insertions(+), 7 deletions(-)

Acked-by: Stefan Hajnoczi <stefanha@redhat.com>

--TybLhxa8M7aNoW+V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXqxewAAoJEJykq7OBq3PIVvIIAJas140huqhE03e6Zq/8v7EK
tbCxPrSBwQJcdc+NjfdvKbyOMFrA6U3nGYTK+gOJSk2LyOlKp9NxoSpJrZ7p4EM6
dG/VYwaWoPwkK29kOo4I6w8UZBIR1js7yk0m9vwH0yxBLvAv+x6XN0q9T2tC18au
zX/YICok+EuAlQ0zQkjgnoRxYhUvKMBe0A621t2XVWffYh42QxVuX8wPeeS0dTbY
p98bUqNNm7dWaP5u2/yR3PTDKHxyme2cDdcKUaAnnAPQK9rUdUEsddsbBdaB/NLe
8zRgzyHUY46FadvSS5FL6akRmkqRR4RlfkP5hvviiY1jWwFeKkkN+Q/TkqNDrws=
=/ywA
-----END PGP SIGNATURE-----

--TybLhxa8M7aNoW+V--

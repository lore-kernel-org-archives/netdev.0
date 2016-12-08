From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH] vhost-vsock: fix orphan connection reset
Date: Thu, 8 Dec 2016 09:19:33 +0000
Message-ID: <20161208091933.GA10780@stefanha-x1.localdomain>
References: <1481103947-76771-1-git-send-email-bergwolf@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
Cc: Stefan Hajnoczi <stefanha@redhat.com>, netdev@vger.kernel.org,
        stable@vger.kernel.org, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org
To: Peng Tao <bergwolf@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481103947-76771-1-git-send-email-bergwolf@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 07, 2016 at 05:45:47PM +0800, Peng Tao wrote:
> local_addr.svm_cid is host cid. We should check guest cid instead,
> which is remote_addr.svm_cid.
>=20
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: stable@vger.kernel.org #4.8+
> Signed-off-by: Peng Tao <bergwolf@gmail.com>
> ---
>  drivers/vhost/vsock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--huq684BweRXVnRxX
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYSSWkAAoJEJykq7OBq3PI0rsH+wcuZhkfOgsQeZ/7sFHdqM4d
jeBW9nE4zWbihMIfospEg+5dZbLVRLq+mZfls99gyhqezNFNwbNnIPzAjFG5IEbA
E8a7ueMXV47VMafiusGiGFnUlHAjTFZOSthVY4S1V7fBZg6Fm6zQpLDZRKAk/0bN
Oi7HAhmGFxPL83OG42MiJaWivxm+ce/t9UiCZDDx6hG9oyQ2F0Y5mq5EZosCWtfX
FJcYANumA/guHZGzuerOTPPpcwLHO7LJMisw3ypMrOWLnDri2ReexfnVd49HXRBL
FkBlXKk1YCjd5wvl6gom8k1LKWTV0BmWYJgowJrYN1EcXtEEWukk+ltKqV03MQo=
=jmP8
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--

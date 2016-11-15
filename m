From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] vhost/vsock: Remove unused but set variable
Date: Tue, 15 Nov 2016 13:00:58 +0000
Message-ID: <20161115130058.GC6012@stefanha-x1.localdomain>
References: <20161111132631.25708-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="YD3LsXFS42OYHhNZ"
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161111132631.25708-1-tklauser@distanz.ch>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--YD3LsXFS42OYHhNZ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 11, 2016 at 02:26:31PM +0100, Tobias Klauser wrote:
> Remove the unused but set variable vq in vhost_transport_send_pkt() to
> fix the following GCC warning when building with 'W=3D1':
>=20
>   drivers/vhost/vsock.c:198:26: warning: variable =E2=80=98vq=E2=80=99 se=
t but not used
>=20
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/vhost/vsock.c | 3 ---
>  1 file changed, 3 deletions(-)

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--YD3LsXFS42OYHhNZ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYKwcKAAoJEJykq7OBq3PI7l4H/2hM846kAdyckXOmKFaWRPCp
POz3MKelNXQbNDDEIUvZ7T1tkspG8HwvrD07Ghxvx+2Q4dGE0YjMlEWHiir47lpb
3Q0KPPwKMMGgBZt8FqJQ7F/2WTcRHivZKTfEsdR6n3xYqAIh5K2NnG6Ees9v/FPQ
ltrQkZhHRXETE3qUeMlH12r0WKvQ+wwFsL2dGp2LJWdshnv7Io1VS1sb11PdSoxl
9i/igk/DsJpCFne1ot8PJSHv/RHi7w2XKvwZ7siWBA4+Fumr+p2kvnlh0aFv8Bz3
P6kcZto9YI7ZGk3EAVgxfcZHVfiGwezrrCR/Wtb/62APcvKecJYSBIZYadWP9KQ=
=q08I
-----END PGP SIGNATURE-----

--YD3LsXFS42OYHhNZ--

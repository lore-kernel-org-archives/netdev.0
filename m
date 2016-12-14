From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] vsock: lookup and setup guest_cid inside vhost_vsock_lock
Date: Wed, 14 Dec 2016 12:39:31 +0000
Message-ID: <20161214123931.GB2643@stefanha-x1.localdomain>
References: <1481714676-18555-1-git-send-email-omarapazanadi@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="+pHx0qQiF2pBVqBT"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, mst@redhat.com
To: Gao feng <omarapazanadi@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1481714676-18555-1-git-send-email-omarapazanadi@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+pHx0qQiF2pBVqBT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 14, 2016 at 07:24:36PM +0800, Gao feng wrote:
> Multi vsocks may setup the same cid at the same time.
>=20
> Signed-off-by: Gao feng <omarapazanadi@gmail.com>
> ---
>  drivers/vhost/vsock.c | 25 +++++++++++++++++--------
>  1 file changed, 17 insertions(+), 8 deletions(-)

Good catch, a classic time-of-check-to-time-of-use race condition.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>

--+pHx0qQiF2pBVqBT
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJYUT2DAAoJEJykq7OBq3PIhR0IAIiLVcFJzqYrHwt0Ns4WkkOF
YA/pUt5woGy9sDlR58jWLoqJj+6zFCjWRyc3icZcZNuym5acfg3dFH/MHb0y3++u
CRLbUljjdGxYoe7UI7lI8RHlH4VLWsZXJZoGzLE7StVB1CYYzvwQ5zI+ui/JRWvA
e6zhiY6tQljIA45/iyXUazVbAxqdL25LRbNeZ+O8FrH0FjwyXFx+JE2b7KQ/84JY
y1GbOY3UAn6QSRvEzj5Ab0uJJmOytfPZ3aW+ieOgR0PtWBi+II/seIQ6AWkmSDt6
/gBJ6fzpE7J/mxJtSQ6NoaZ9y4yY18ftPAXVIBwrkB5OhDdxW0Zx/loynxC0dyk=
=Bu+C
-----END PGP SIGNATURE-----

--+pHx0qQiF2pBVqBT--

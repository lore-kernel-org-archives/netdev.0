From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH] VSOCK: fix vhost virtio_vsock_pkt use-after-free
Date: Fri, 5 Aug 2016 09:44:35 +0100
Message-ID: <20160805084435.GB15955@stefanha-x1.localdomain>
References: <1470318773-10414-1-git-send-email-stefanha@redhat.com>
 <20160804193338-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Fba/0zbH8Xs+Fj9o"
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	Dan Carpenter <dan.carpenter@oracle.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757779AbcHEIwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Aug 2016 04:52:31 -0400
Content-Disposition: inline
In-Reply-To: <20160804193338-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Fba/0zbH8Xs+Fj9o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 04, 2016 at 07:34:43PM +0300, Michael S. Tsirkin wrote:
> On Thu, Aug 04, 2016 at 02:52:53PM +0100, Stefan Hajnoczi wrote:
> > Stash the packet length in a local variable before handing over
> > ownership of the packet to virtio_transport_recv_pkt() or
> > virtio_transport_free_pkt().
> >=20
> > This patch solves the use-after-free since pkt is no longer guaranteed
> > to be alive.
> >=20
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
>=20
>=20
> Thanks!
> I'd prefer a lower-case prefix, mentioning vhost, such as vhost/vsock.
> I'll tweak it for now.

Thanks, I will use vhost/vsock in the future.

Stefan

--Fba/0zbH8Xs+Fj9o
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJXpFHzAAoJEJykq7OBq3PIuTIIAK7hJrVhJRRqTDbDEDDK9hub
tdTlC9vEeenJkaONV68d1E9qQDfvaouVKGbXzrJq+3dQ5cC0fmMkps8fY0BE3JeB
PG37Hr8Hah4XpU9cOjkmMQT8Com7u51m9iFoL4zslehECcttw82oB1gP430tksak
iSmWQhBPqt6ijhVVa38m0OEyctIbAaMdQCPXnJbL4VSUNnlMEhLhIaa3DikhD7Cm
74H15SiE3U9OKoV5Q4FfsZAE+huNXC5rGKx6FicBCQAOin5291u7usezIg5zqgNb
yLWAdzyXYuC8/xmKhJ2aP6ArHqo3NZqucNu0ke3tdWjzJwjtYOW2I2SUXosN+DI=
=C5n7
-----END PGP SIGNATURE-----

--Fba/0zbH8Xs+Fj9o--

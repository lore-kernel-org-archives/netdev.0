From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: [patch] tg3 ring buffer allocation error handling
Date: Thu, 15 Apr 2004 00:02:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040414220254.GA24974@zion.homelinux.com>
References: <20040414184642.GZ1175@waste.org> <20040414205959.GA22051@zion.homelinux.com> <20040414214510.GH1175@waste.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k+w/mQv8wyuph6w0"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20040414214510.GH1175@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k+w/mQv8wyuph6w0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 14, 2004 at 04:45:10PM -0500, Matt Mackall told us:
> > Please correct me if I'm wrong, but shouldn't the buffers from the=20
> > irst allocation (RXD_OPAQUE_RING_STD) be freed (maybe via=20
> > tg3_free_rings??) when we get an error here??
>=20
> The buffers are freed in the module release path, which is invoked
> when we return failure here. Without this, we don't notice the
> allocation failure and instead blow up when we get traffic.

So thanks for correcting me :-) should have taken a closer look at
the tg3 source.


Sven

>=20
> FYI, I last tested this on a mem=3D4M box, where it was very obvious
> that the 1M of ring buffers weren't leaking.
>=20
> --=20
> Matt Mackall : http://www.selenic.com : Linux development and consulting

--=20
Linux zion 2.6.5 #1 Sun Apr 4 19:56:55 CEST 2004 i686 athlon i386 GNU/Linux
 00:01:49  up 10 days, 45 min,  2 users,  load average: 0.06, 0.05, 0.02

--k+w/mQv8wyuph6w0
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQFAfbUOo4FAdB2PneQRAtKvAJwNfiUfBoT9Q6OD9kCuAFv3GBnUNQCeJMfE
xzfCMYMdQdvokJAojtkiYqQ=
=gWm3
-----END PGP SIGNATURE-----

--k+w/mQv8wyuph6w0--

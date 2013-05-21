From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 0/5] perf: net_dropmonitor: Make it work and make it fast
Date: Tue, 21 May 2013 14:54:00 +0100
Message-ID: <1369144440.3469.181.camel@deadeye.wl.decadent.org.uk>
References: <1369096976.3469.131.camel@deadeye.wl.decadent.org.uk>
	 <20130521133355.GA3613@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+T9vp5LhkE5Kws61d6IM"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Paul Mackerras <paulus@samba.org>,
	Ingo Molnar <mingo@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130521133355.GA3613@neilslaptop.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-+T9vp5LhkE5Kws61d6IM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-05-21 at 09:33 -0400, Neil Horman wrote:
> On Tue, May 21, 2013 at 01:42:56AM +0100, Ben Hutchings wrote:
> > Somewhat surprisingly, the net_dropmonitor reporting script doesn't wor=
k
> > at all.  This series fixes it and then makes it slightly more efficient=
.
> >=20
> > Ben.
> >=20
> It worked fine when I first submitted it.  I wonder if there was a paramt=
er
> order change at some point that I wasn't CC'ed on.

The parameter order for the trace event changed in 2.6.39, but that was
before this script went in.

Ben.

> Either way, this all looks good.  Thanks Ben.
>=20
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
>=20
> > Ben Hutchings (5):
> >   perf: net_dropmonitor: Fix trace parameter order
> >   perf: net_dropmonitor: Fix symbol-relative addresses
> >   perf: net_dropmonitor: Do not assume ordering of dictionaries
> >   perf: net_dropmonitor: Use bisection in symbol lookup
> >   perf: net_dropmonitor: Remove progress indicator
> >=20
> >  tools/perf/scripts/python/net_dropmonitor.py |   39 ++++++++++++++----=
--------
> >  1 file changed, 21 insertions(+), 18 deletions(-)
> >=20
> >=20
>=20
>=20

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-+T9vp5LhkE5Kws61d6IM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUZt8eOe/yOyVhhEJAQo7gA/9FLWw7cJaA1v1e5mRcI7lZQlHAPaVc1iK
WhaFNqw2QNl+ssqO7xJWvNR1WpVNe/pBPI38dF7iHcVW04KmXBh6dNzSpZN0X67y
9Tb5xaPjJTLYF8MVAzUE18L4tE/I7+ZZaaaDD6Xm7SQEyr0DTvG0T5pGIpM10Dqo
uhk3O9hQzQzcx/M3aG3sz061Z7QU8JIViJmg72fnxVS55oV1vYVFobkG6hNwoB8C
8iOamGCGiCOW4yCoW8lAmkpXi7AfbdKvRoiQ6NVLFXhk3qU9H4AHPrcvc+JIpGWs
3BySblSl1TvLEYGpseMy2uCy7HDms9kksMELc/Q4v1ARZnETI6d3AmExJ/vV0Qr+
jpPnco73M5LMedyO/X/XP9HAcoD+Lzg/T8n9MRFvaeebElnEA/4rrjwHU2gExy7+
efvjtD585Jvs4U4Pbd8ujev6767rKrh2kvKBNpivSyf8cVP+UPspRqwvfpp8XvMK
1pMMJDzIb12Ei6WFdOm32OAXquWdE4JqNbf8dItUvk9pn5lVfj7MzDwDcOigEvZ8
PXrDUU55fC6jmUFOuMgWYriJjYwfSMLnLAK7U9Mf9VWWOrsSeAaQfpf+Lg9X16lD
bIazFY6C06piMRq5elEh497JuQmOo+InHAWwTq4cwhClEc9nwrp3/I0MHDmztumf
/vzLwJZ5wj8=
=88Sp
-----END PGP SIGNATURE-----

--=-+T9vp5LhkE5Kws61d6IM--

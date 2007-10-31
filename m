From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 03/33] mm: slub: add knowledge of reserve pages
Date: Wed, 31 Oct 2007 13:54:18 +0100
Message-ID: <1193835258.27652.199.camel@twins>
References: <20071030160401.296770000@chello.nl>
	 <200710312146.03351.nickpiggin@yahoo.com.au>
	 <1193833072.27652.167.camel@twins>
	 <200710312225.07249.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1JONk1CHaR7M71QTq2Rs"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759145AbXJaMyh@vger.kernel.org>
In-Reply-To: <200710312225.07249.nickpiggin@yahoo.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1JONk1CHaR7M71QTq2Rs
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 22:25 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 23:17, Peter Zijlstra wrote:
> > On Wed, 2007-10-31 at 21:46 +1100, Nick Piggin wrote:
>=20
> > > And I'd prevent these ones from doing so.
> > >
> > > Without keeping track of "reserve" pages, which doesn't feel
> > > too clean.
> >
> > The problem with that is that once a slab was allocated with the right
> > allocation context, anybody can get objects from these slabs.
>=20
> [snip]
>=20
> I understand that.
>=20
>=20
> > So we either reserve a page per object, which for 32 byte objects is a
> > large waste, or we stop anybody who doesn't have the right permissions
> > from obtaining objects. I took the latter approach.
>=20
> What I'm saying is that the slab allocator slowpath should always
> just check watermarks against the current task. Instead of this
> ->reserve stuff.

So what you say is to allocate a slab every time we take the slow path,
even when we already have one?

That sounds rather sub-optimal.

--=-1JONk1CHaR7M71QTq2Rs
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKHr6XA2jU0ANEf4RAm9gAJ9xM3miH4H0KzYn+MEPjt6I1zY3swCdEN3/
FchO1Oe5ngFrcknUFRAg2jQ=
=2VhI
-----END PGP SIGNATURE-----

--=-1JONk1CHaR7M71QTq2Rs--

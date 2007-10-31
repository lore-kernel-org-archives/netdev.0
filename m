From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 05/33] mm: kmem_estimate_pages()
Date: Wed, 31 Oct 2007 11:42:38 +0100
Message-ID: <1193827358.27652.128.camel@twins>
References: <20071030160401.296770000@chello.nl>
	 <20071030160911.281698000@chello.nl>
	 <200710311443.18143.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-B/evvxB9qIXk4AH3ka2B"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep18-int.chello.at ([213.46.255.22]:31204 "EHLO
	viefep33-int.chello.at" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754988AbXJaKmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 06:42:46 -0400
In-Reply-To: <200710311443.18143.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-B/evvxB9qIXk4AH3ka2B
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 14:43 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > Provide a method to get the upper bound on the pages needed to allocate
> > a given number of objects from a given kmem_cache.
> >
>=20
> Fair enough, but just to make it a bit easier, can you provide a
> little reason of why in this patch (or reference the patch number
> where you use it, or put it together with the patch where you use
> it, etc.).

A generic reserve framework, as seen in patch 11/23, needs to be able
convert from a object demand (kmalloc() bytes, kmem_cache_alloc()
objects) to a page reserve.


--=-B/evvxB9qIXk4AH3ka2B
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKFweXA2jU0ANEf4RAg3yAJ40xHIOL90VMpb0RQnEM1N4VoRmRgCfUuHc
jGUE2pI/amo9+MDzmA9+R3k=
=lGAV
-----END PGP SIGNATURE-----

--=-B/evvxB9qIXk4AH3ka2B--


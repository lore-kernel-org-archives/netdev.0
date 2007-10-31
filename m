From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 00/33] Swap over NFS -v14
Date: Wed, 31 Oct 2007 12:27:13 +0100
Message-ID: <1193830033.27652.159.camel@twins>
References: <20071030160401.296770000@chello.nl>
	 <200710311426.33223.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-H8xFTlN2az+i59IqNUDQ"
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:39711 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755107AbXJaL1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 07:27:17 -0400
In-Reply-To: <200710311426.33223.nickpiggin@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-H8xFTlN2az+i59IqNUDQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 14:26 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > Hi,
> >
> > Another posting of the full swap over NFS series.
>=20
> Hi,
>=20
> Is it really worth all the added complexity of making swap
> over NFS files work, given that you could use a network block
> device instead?

As it stands, we don't have a usable network block device IMHO.
NFS is by far the most used and usable network storage solution out
there, anybody with half a brain knows how to set it up and use it.

> Also, have you ensured that page_file_index, page_file_mapping
> and page_offset are only ever used on anonymous pages when the
> page is locked? (otherwise PageSwapCache could change)

Good point, I hope so, both ->readpage() and ->writepage() take a locked
page, I'd have to look if it remains locked throughout the NFS call
chain.

Then again, it might become obsolete with the extended swap a_ops.


--=-H8xFTlN2az+i59IqNUDQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHKGaRXA2jU0ANEf4RApFUAJ4+CBvPm0mCVlIMmXKt1KBmtVP/3wCfWg+f
0Bv7xVApLAX9gH4Chrrlb70=
=IEK+
-----END PGP SIGNATURE-----

--=-H8xFTlN2az+i59IqNUDQ--


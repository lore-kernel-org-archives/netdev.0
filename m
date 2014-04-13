From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.2-3.12] skbuff: skb_segment: orphan frags before
 copying
Date: Mon, 14 Apr 2014 00:50:10 +0100
Message-ID: <1397433010.10849.93.camel@deadeye.wl.decadent.org.uk>
References: <20140410.215420.576903689381200176.davem@davemloft.net>
	 <1397392513.10849.75.camel@deadeye.wl.decadent.org.uk>
	 <1397429860.10849.86.camel@deadeye.wl.decadent.org.uk>
	 <20140413.192018.492900316749077186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4Z5k7R7an1Xl9eubxJmY"
Cc: stable@vger.kernel.org, mst@redhat.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:52626 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750788AbaDMXuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 19:50:20 -0400
In-Reply-To: <20140413.192018.492900316749077186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4Z5k7R7an1Xl9eubxJmY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-04-13 at 19:20 -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 13 Apr 2014 23:57:40 +0100
>=20
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> >=20
> > commit 1fd819ecb90cc9b822cd84d3056ddba315d3340f upstream.
> >=20
> > skb_segment copies frags around, so we need
> > to copy them carefully to avoid accessing
> > user memory after reporting completion to userspace
> > through a callback.
> >=20
> > skb_segment doesn't normally happen on datapath:
> > TSO needs to be disabled - so disabling zero copy
> > in this case does not look like a big deal.
> >=20
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > [bwh: Backported to 3.2.  As skb_segment() only supports page-frags *or=
* a
> >  frag list, there is no need for the additional frag_skb pointer or the
> >  preparatory renaming.]
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> > ---
> > For branches older than 3.6, commit a353e0ce0fd4 ('skbuff: add an api t=
o
> > orphan frags') is needed before this.  This is untested and I would
> > appreciate a review.
>=20
> I didn't do this backport because it seemed risky unless Michael
> or someone else tested it thoroughly.

Understood; I'll wait for further feedback.

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.

--=-4Z5k7R7an1Xl9eubxJmY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU0sisue/yOyVhhEJAQrzSw//cu925YXpfEVjxMuOgtrDQG4AMS2EOv4T
DXXMFZakCPPiEZEZGZyLiRYDnUU4DY5FaQzbBqefgFwzyrdzLjDq+oJt2/uB9Qcv
q0jFm4Spx4z5EJzA8AbBKj3WkGUqq2eFdVM1ZxRpccWfZhAWkZuWoaVA5Ehqc9yq
FH3cdLedGdtM4P+eacQX8/SfzPhLma0NzVwkhmDXdRUSKRIpG65hgxFkr83uBrZe
62xAedp05cwD2cBuQUDnUwppYORpVgEgceeZrCIYZ48WXVtXBcPrkI7N8vYHohgb
Unq5Px1JoGgbvARCWXugkgPWLVvGofNCoVmipoglj0OzjUqLoJ02ofdF4LYcQOBV
ez6n6ipcHAgr5OVTokncMxDXFYiTLbfwwqdMBM0SRcVw2OePUZSgni5EVV4c+lht
4I9e62VBqTiLlOzQsNqLJVrNUF/SQD1QWv1+RQrDxFTbxqAoXRkl50x1cfvIaS9X
Nj78+L1CCPIK5crEcTm0mkpxa9rqg9MRVcwnilMilWGuIbe1v0ZZDjcTc8tdML4o
UlxbtH0pg8de7BKKx7lmjgz1UKoqXzb+3AbWyS881mbMIaZie3DRwk07DfEF5Dqc
enpWeTtslzic6XJEkA9MAxyz7+9d3A2/8s+FK30HI9Gd5wyMfszaj1vixKKaNPRP
vlaX7zLtye4=
=/Tnb
-----END PGP SIGNATURE-----

--=-4Z5k7R7an1Xl9eubxJmY--

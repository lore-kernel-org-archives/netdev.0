From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless extensions: play with netns
Date: Thu, 18 Jun 2009 02:35:21 +0200
Message-ID: <1245285321.31588.75.camel@johannes.local>
References: <1245263058.31588.38.camel@johannes.local>
	 <m1y6rqwpur.fsf@fess.ebiederm.org>
	 <1245276899.31588.57.camel@johannes.local>
	 <m1r5xitpdh.fsf@fess.ebiederm.org>
	 <1245282099.31588.69.camel@johannes.local>
	 <1245282315.31588.71.camel@johannes.local>
	 <m18wjqs7x4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-o/b8sLPUEjy3s79FMXvp"
Cc: John Linville <linville@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:46201 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbZFRAfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 20:35:52 -0400
In-Reply-To: <m18wjqs7x4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-o/b8sLPUEjy3s79FMXvp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-17 at 17:27 -0700, Eric W. Biederman wrote:

> > Subject: genetlink: make netns aware
> >
> > This makes generic netlink network namespace aware.
> > No actual generic netlink families are made namespace
> > aware, they need to be checked one by one and then
> > set the family->netnsok member to true.
>=20
> Are skb_clone and nlmsg_multicast really guaranteed not to sleep?

Yes, definitely, we call them in atomic callbacks already in various
places. There are many callers that use the existing genlmsg_multicast()
in atomic contexts.

johannes

--=-o/b8sLPUEjy3s79FMXvp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOYu7AAoJEODzc/N7+QmadTQQAI2yvGnGUpHXL9118eqUVBTq
rGXHTB1IVHQEF2CynksnSQ9MvjhkaDVHsWxteERvKKo9oWmPFaL7idMBE0INoyWg
Q5yOXN8O1em5tm7bs9qaSLoh+9IhaC3eO7gz6xyoSMzez7XhcFBsd9a9EYsEJL+E
3f5V6t3sL7pEy3T8RxvbAv3XvRJWWNJwh514AaTwLQ1HWEWjgYkwTJt5h1Rklkzf
XuzrBkgg9ub7gkXfLgxK+nAYGz4ROvNi84vpB1oLWr5LvQ8JgzJXl3/16QN0TvSz
hLCJUS63CSWB8ZmUpitUK3/k5RgiJ/lVR1f0jh+JPXKICEbcGARfx5KlD4B+E3LQ
tZqy2OGtrXpGkuZUJpaUdiWcjPSLNOKCyGKXiHbhsdS/uHGiIAOshgOFdidrAXBh
0NYnP5zFabJR3zyCz6TslKZdy/irw/WgwTX8VBxuO7/FxKIXhO3WJBeNDn9kMyGC
2zlYAG+pFv+JN3tuWabeWXU4yV8ui8Mv1dqp8SoxO3Kixqq8FvUMElN2UHrBlJJx
Hvi0uTYWp3zQBa6P5eZ0Rg7JG5p984HNFJwpJuPOkltTOszSK44wvw8LUKto33ww
XxuPkyN1ZO13+Ju8iXJADqZr9YyskG3snUUDOnYyjXmUF42Nwx38yLOKralto0Zx
iDnpuShE/vcwDaCbv8TD
=tK3N
-----END PGP SIGNATURE-----

--=-o/b8sLPUEjy3s79FMXvp--


From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] icmpv6fuzz creates bad paging request
Date: Fri, 2 Jan 2009 20:05:15 +1100
Message-ID: <20090102090515.GA25796@gondor.apana.org.au>
References: <20090101201304.GA6698@alice> <Pine.LNX.4.64.0901021040050.6207@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Sesterhenn <snakebyte@gmx.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	Yang Hongyang <yanghy@cn.fujitsu.com>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:36547 "EHLO arnor.apana.org.au"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751304AbZABJJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 04:09:14 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0901021040050.6207@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 02, 2009 at 08:53:18AM +0000, Ilpo J=E4rvinen wrote:
>=20
> Can you try the patch below.

You beat me to it :)

> I wonder btw what's the correct policy wrt. those optval =3D=3D NULL =
checks=20
> that's visible in the patch' context (IPV6_PKTINFO is the only one wh=
ich
> is doing that while many there fetch to sizeof(struct something)).

copy_from_user will catch bogus pointers so no extra checks are
necessary.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

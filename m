From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] icmpv6fuzz creates bad paging request
Date: Sun, 04 Jan 2009 17:28:21 -0800 (PST)
Message-ID: <20090104.172821.105803003.davem@davemloft.net>
References: <20090101201304.GA6698@alice>
	<Pine.LNX.4.64.0901021040050.6207@wrl-59.cs.helsinki.fi>
	<20090102090515.GA25796@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, snakebyte@gmx.de,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	yanghy@cn.fujitsu.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37744
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750772AbZAEB2R convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jan 2009 20:28:17 -0500
In-Reply-To: <20090102090515.GA25796@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 2 Jan 2009 20:05:15 +1100

> On Fri, Jan 02, 2009 at 08:53:18AM +0000, Ilpo J=E4rvinen wrote:
> >=20
> > Can you try the patch below.
>=20
> You beat me to it :)

I applied Ilpo's version, because he won :-)  Thanks everyone.

> > I wonder btw what's the correct policy wrt. those optval =3D=3D NUL=
L checks=20
> > that's visible in the patch' context (IPV6_PKTINFO is the only one =
which
> > is doing that while many there fetch to sizeof(struct something)).
>=20
> copy_from_user will catch bogus pointers so no extra checks are
> necessary.

Right.

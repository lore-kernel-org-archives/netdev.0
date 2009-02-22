From: David Miller <davem@davemloft.net>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Sat, 21 Feb 2009 23:53:08 -0800 (PST)
Message-ID: <20090221.235308.172360407.davem@davemloft.net>
References: <Pine.LNX.4.64.0902091513190.31742@wrl-59.cs.helsinki.fi>
	<20090221132424.GA28861@gondor.apana.org.au>
	<Pine.LNX.4.64.0902212042420.20526@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, jeff.chua.linux@gmail.com,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45524
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752175AbZBVHx0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 02:53:26 -0500
In-Reply-To: <Pine.LNX.4.64.0902212042420.20526@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 21 Feb 2009 20:54:11 +0200 (EET)

> On Sat, 21 Feb 2009, Herbert Xu wrote:
>=20
> > On Mon, Feb 09, 2009 at 03:28:09PM +0200, Ilpo J=E4rvinen wrote:
> > >
> > > Yes, that should work too except the gcc catchable typo.
> >=20
> > Thanks, so let's try again for net-next:
> >=20
> > tcp: Always set urgent pointer if it's beyond snd_nxt
 ...
> I thought this through already at the last time... so I think it real=
ly=20
> should work in all cases I could think of (including the below window=
=20
> probes whose existance is not very obvious before they bite back :-))=
:
>=20
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> But I mostly agree with Linus that URG is legacy that would be good
> to just deprecate instead of trying to "fix" it.

Sure, but I'll give Herbert one more chance :-)

Applied to net-next-2.6

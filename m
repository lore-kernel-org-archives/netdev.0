From: David Miller <davem@davemloft.net>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 20:36:58 -0800 (PST)
Message-ID: <20071220.203658.19427671.davem@davemloft.net>
References: <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
	<20071220.035621.147230372.davem@davemloft.net>
	<476A920D.6020401@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35861
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753254AbXLUEg6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 23:36:58 -0500
In-Reply-To: <476A920D.6020401@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: John Heffner <jheffner@psc.edu>
Date: Thu, 20 Dec 2007 11:02:21 -0500

> David Miller wrote:
> > From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Thu, 20 Dec 2007 13:40:51 +0200 (EET)
> >=20
> >> [PATCH] [TCP]: Fix TSO deferring
> >>
> >> I'd say that most of what tcp_tso_should_defer had in between
> >> there was dead code because of this.
> >>
> >> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> >=20
> > Yikes!!!!!
> >=20
> > John, we've been living a lie for more than a year. :-/
> >=20
> > On the bright side this explains a lot of small TSO frames I've bee=
n
> > seeing in traces over the past year but never got a chance to
> > investigate.
>=20
> Ouch.  This fix may improve some benchmarks.
>=20
> Re-checking this function was on my list of things to do because I ha=
d=20
> also noticed some TSO frames that seemed a bit small.  This clearly=20
> explains it.

What I'll do for now is I'll put this into net-2.6.25 to let it
"cook" for a while.  It's an obvious fix but it's enabling code
that's effectively been disabled for more than a year so something
might turn up that we need to fix.

From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 09:56:01 +0100
Message-ID: <20091203085601.GC30730@sd-11162.dedibox.fr>
References: <20091130195004.38dbc319@houba> <alpine.DEB.2.00.0911302113390.9826@melkinpaasi.cs.helsinki.fi> <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba> <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:38523 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992AbZLCIzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 03:55:55 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 02, 2009 at 06:05:24PM +0200, Ilpo J=E4rvinen wrote:
>
> In the recent work, the most suspicious things are the new timeout th=
ings,=20
> I'll read them through once I've some time (but so far I've not found=
=20
> anything wrong in them but I of course can miss something subtle). =20
> ...I've added Damian as CC if he has some idea. If you want you can t=
ry=20
> with a trivial revert of that stuff, I've included a patch for that b=
elow.

> [PATCH] Revert new RTO backoff stuff

So I recompiled my kernel with linus-stable tree. It works (bad) as the=
 tuxonice 2.6.32-rc5.
All further test are on linus-stable tree.

I made 3 test with your patch. All 3 copy worked well.
So it's in the new RTO backoff.

I made only one trace (.9).

--=20
=46r=E9d=E9ric Leroy

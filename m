From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
 destructor
Date: Mon, 05 May 2008 12:08:11 -0700 (PDT)
Message-ID: <20080505.120811.211603587.davem@davemloft.net>
References: <1209972675.3655.15.camel@johannes.berg>
	<20080505.004017.247102504.davem@davemloft.net>
	<Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42362
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751406AbYEETIL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 15:08:11 -0400
In-Reply-To: <Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 5 May 2008 12:43:25 +0300 (EEST)

> On Mon, 5 May 2008, David Miller wrote:
>=20
> > From: Johannes Berg <johannes@sipsolutions.net>
> > Date: Mon, 05 May 2008 09:31:15 +0200
> >=20
> > > If we decide to uninline those functions for another reason (used=
 too
> > > much, code size, ...) then we can still do that.
> >=20
> > Agreed.
>=20
> According to my measurements the size bloat of those two is
> (x86/32bit, gcc 4.1.2 redhat something):
>=20
> -1091  40 funcs, 89 +, 1180 -, diff: -1091 --- skb_set_owner_r
> -495  46 funcs, 70 +, 565 -, diff: -495 --- skb_set_owner_w

That's not too bad, but adding the WARN_ON() we're discussing
will plump that up a bit, percentage wise, which is why I
said we should inline it in such a case.

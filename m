From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] [NET] warn when accounting an skb that already has a
	destructor
Date: Mon, 5 May 2008 18:57:44 -0300
Message-ID: <20080505215744.GD21070@ghostprotocols.net>
References: <1209972675.3655.15.camel@johannes.berg> <20080505.004017.247102504.davem@davemloft.net> <Pine.LNX.4.64.0805051241240.21115@wrl-59.cs.helsinki.fi> <20080505.120811.211603587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, johannes@sipsolutions.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51674 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758259AbYEEV6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2008 17:58:00 -0400
Content-Disposition: inline
In-Reply-To: <20080505.120811.211603587.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, May 05, 2008 at 12:08:11PM -0700, David Miller escreveu:
> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 5 May 2008 12:43:25 +0300 (EEST)
>=20
> > On Mon, 5 May 2008, David Miller wrote:
> >=20
> > > From: Johannes Berg <johannes@sipsolutions.net>
> > > Date: Mon, 05 May 2008 09:31:15 +0200
> > >=20
> > > > If we decide to uninline those functions for another reason (us=
ed too
> > > > much, code size, ...) then we can still do that.
> > >=20
> > > Agreed.
> >=20
> > According to my measurements the size bloat of those two is
> > (x86/32bit, gcc 4.1.2 redhat something):
> >=20
> > -1091  40 funcs, 89 +, 1180 -, diff: -1091 --- skb_set_owner_r
> > -495  46 funcs, 70 +, 565 -, diff: -495 --- skb_set_owner_w
>=20
> That's not too bad, but adding the WARN_ON() we're discussing
> will plump that up a bit, percentage wise, which is why I
> said we should inline it in such a case.

s/inline/uninline/g

According to some long e-mail today its worth ~198 unexport patches! 8-=
)

- Arnaldo

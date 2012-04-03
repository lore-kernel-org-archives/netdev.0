From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 11:35:38 +0200
Message-ID: <20120403093538.GA20140@1984>
References: <1333424902.18626.36.camel@edumazet-glaptop>
 <20120403081728.GA19753@1984>
 <1333441883.18626.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51256 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353Ab2DCJfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 05:35:43 -0400
Content-Disposition: inline
In-Reply-To: <1333441883.18626.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 03, 2012 at 10:31:23AM +0200, Eric Dumazet wrote:
> On Tue, 2012-04-03 at 10:17 +0200, Pablo Neira Ayuso wrote:
> > On Tue, Apr 03, 2012 at 05:48:22AM +0200, Eric Dumazet wrote:
> > > If CONFIG_NF_CONNTRACK_TIMEOUT=3Dn we have following warning :
> > >=20
> > >   CC [M]  net/netfilter/xt_CT.o
> > > net/netfilter/xt_CT.c: In function =E2=80=98xt_ct_tg_check_v1=E2=80=
=99:
> > > net/netfilter/xt_CT.c:284: warning: label =E2=80=98err4=E2=80=99 =
defined but not used
> >=20
> > Thanks Eric.
> >=20
> > I think I prefer the one attached.
> >=20
> > I 'll pass it to davem with a couple of other minor fixes anytime s=
oon.
>=20
> Its your call, but you should move the whole
>=20
> #if CONFIG_NF_CONNTRACK_TIMEOUT
> 	... lot of lines ...
> #endif
>=20
> in a helper function to make things a bit more maintainable

I will, thanks for the suggestion.

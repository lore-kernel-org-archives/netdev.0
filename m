From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 15:06:59 +0100
Message-ID: <1298988419.3284.107.camel@edumazet-laptop>
References: <20110228163742.GH9763@canuck.infradead.org>
	 <1298912869.2941.687.camel@edumazet-laptop>
	 <20110301101955.GI9763@canuck.infradead.org>
	 <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
	 <1298977984.3284.15.camel@edumazet-laptop>
	 <20110301112759.GK9763@canuck.infradead.org>
	 <1298979909.3284.28.camel@edumazet-laptop>
	 <20110301121829.GM9763@canuck.infradead.org>
	 <20110301121951.GA7267@gondor.apana.org.au>
	 <20110301135053.GA6684@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:32993 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619Ab1CAOHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 09:07:08 -0500
Received: by bwz15 with SMTP id 15so4592339bwz.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 06:07:06 -0800 (PST)
In-Reply-To: <20110301135053.GA6684@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 08:50 -0500, Thomas Graf a =C3=A9crit :
> On Tue, Mar 01, 2011 at 08:19:51PM +0800, Herbert Xu wrote:
> > On Tue, Mar 01, 2011 at 07:18:29AM -0500, Thomas Graf wrote:
> > >
> > >=20
> > > ... makes it use CPU 5 for rxq2 and the qps goes up from 250kqps =
to 270kqps
> >=20
> > I think the increase here comes from the larger number of packets
> > in flight more than anything.
> >=20
> > The bottleneck is still the TX queue (both software and hardware).
>=20
> Disabled netfilter and reran test
>=20
> Now does ~316kqps (rx was split over 2 queues)

Would be nice to cpu affine named to _not_ run on CPU11, just to
specialize it for TX completions and have softirq time percentage and
"perf top -C 11 " results

Thanks



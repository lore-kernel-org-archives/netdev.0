From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Thu, 16 Dec 2010 15:29:35 +0100
Message-ID: <1292509775.2883.187.camel@edumazet-laptop>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
	 <1292508733.2883.152.camel@edumazet-laptop>
	 <1292509489.31289.20.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>,
	Steven Rostedt <srostedt@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292509489.31289.20.camel@firesoul.comx.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 16 d=C3=A9cembre 2010 =C3=A0 15:24 +0100, Jesper Dangaard Brou=
er a
=C3=A9crit :

> In my case I think this will not help. I'll kill the cache anyways, a=
s
> the ruleset is 19MB and my CPU cache is 8MB.
>=20
>=20

Yep ;)

By the way, you speak of a 'possible regression', but we always masked
BH while doing get_counters().

Only very recent kernels are masking them for each unit (cpu) of work.

There was attempt to use a lockless read for each counter (using a
seqlock), but it was not completed. I guess we could do something to
ressurect this idea.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

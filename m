From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Wed, 06 Apr 2011 06:42:07 +0200
Message-ID: <1302064927.3020.1.camel@edumazet-laptop>
References: <20110404194856.GA3720@dannf.org> <4D9A23BC.4010505@trash.net>
	 <1301949477.3021.55.camel@edumazet-laptop>
	 <1301957293.3021.191.camel@edumazet-laptop>
	 <1301984679.3021.655.camel@edumazet-laptop>
	 <1301987879.3021.714.camel@edumazet-laptop>
	 <20110405234216.GD32579@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, dann frazier <dannf@dannf.org>,
	netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110405234216.GD32579@Chamillionaire.breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 06 avril 2011 =C3=A0 01:42 +0200, Florian Westphal a =C3=A9=
crit :

> using ninfo->nentries does not always work because ebtables compat
> can call xt_compat_add_offset() more than once per entry.
>=20

With same offset ? Maybe we should tweak xt_compat_add_offset() to
detect this and add delta to previous delta in this case

> That is of course not necessary; the ebt compat code should do better=
=2E
> I plan to look at this in the evening.


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

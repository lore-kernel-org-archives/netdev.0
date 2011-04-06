From: Florian Westphal <fw@strlen.de>
Subject: Re: shutdown oops in xt_compat_calc_jump
Date: Wed, 6 Apr 2011 09:40:47 +0200
Message-ID: <20110406074047.GE32579@Chamillionaire.breakpoint.cc>
References: <20110404194856.GA3720@dannf.org>
 <4D9A23BC.4010505@trash.net>
 <1301949477.3021.55.camel@edumazet-laptop>
 <1301957293.3021.191.camel@edumazet-laptop>
 <1301984679.3021.655.camel@edumazet-laptop>
 <1301987879.3021.714.camel@edumazet-laptop>
 <20110405234216.GD32579@Chamillionaire.breakpoint.cc>
 <1302064927.3020.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>, Patrick McHardy <kaber@trash.net>,
	dann frazier <dannf@dannf.org>, netdev@vger.kernel.org,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1302064927.3020.1.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le mercredi 06 avril 2011 =E0 01:42 +0200, Florian Westphal a =E9crit=
 :
>=20
> > using ninfo->nentries does not always work because ebtables compat
> > can call xt_compat_add_offset() more than once per entry.
> >=20
>=20
> With same offset ? Maybe we should tweak xt_compat_add_offset() to
> detect this and add delta to previous delta in this case

No, different offset (it calls it per match/watcher/target instead
of summing up the match/target deltas and using that in a single
add_offset call).
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Florian Mickler <florian@mickler.org>
Subject: Re: [PATCH][RESEND] netfilter: fix CONFIG_COMPAT support
Date: Mon, 30 Aug 2010 16:10:37 +0200
Message-ID: <20100830161037.517d6ea5@schatten.dmk.lab>
References: <1282568186-20475-1-git-send-email-fw@strlen.de>
	<20100823.144146.173873857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100823.144146.173873857.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 23 Aug 2010 14:41:46 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Florian Westphal <fw@strlen.de>
> Date: Mon, 23 Aug 2010 14:56:26 +0200
> 
> > commit f3c5c1bfd430858d3a05436f82c51e53104feb6b
> > (netfilter: xtables: make ip_tables reentrant) forgot to
> > also compute the jumpstack size in the compat handlers.
> > 
> > Result is that "iptables -I INPUT -j userchain" turns into -j DROP.
> > 
> > Reported by Sebastian Roesner on #netfilter, closes
> > http://bugzilla.netfilter.org/show_bug.cgi?id=669.
> > 
> > Note: arptables change is compile-tested only.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied, thanks Florian.
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Should this go to stable? 
It seems commit f3c5c1bdf was introduced in 2.6.35.

It fixes 
	[Bug #16423] netfilter/iptables stopped logging 2.6.35-rc 
which was tracked as a regression.

Cheers,
Flo

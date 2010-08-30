From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH][RESEND] netfilter: fix CONFIG_COMPAT support
Date: Mon, 30 Aug 2010 23:50:04 +0200
Message-ID: <20100830215004.GD17484@Chamillionaire.breakpoint.cc>
References: <1282568186-20475-1-git-send-email-fw@strlen.de>
 <20100823.144146.173873857.davem@davemloft.net>
 <20100830161037.517d6ea5@schatten.dmk.lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Mickler <florian@mickler.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100830161037.517d6ea5@schatten.dmk.lab>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Mickler <florian@mickler.org> wrote:
> On Mon, 23 Aug 2010 14:41:46 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Florian Westphal <fw@strlen.de>
> > Date: Mon, 23 Aug 2010 14:56:26 +0200
> > 
> > > commit f3c5c1bfd430858d3a05436f82c51e53104feb6b
> > > (netfilter: xtables: make ip_tables reentrant) forgot to
> > > also compute the jumpstack size in the compat handlers.
> > > 
> > > Result is that "iptables -I INPUT -j userchain" turns into -j DROP.
[..]
> 
> Should this go to stable? 
> It seems commit f3c5c1bdf was introduced in 2.6.35.

My bad, I forgot to add a "Cc: stable" tag.
I'll submit it now, thanks for the heads-up...

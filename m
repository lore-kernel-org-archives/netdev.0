From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] x_table: align per cpu xt_counter
Date: Thu, 18 Jun 2015 21:04:34 +0200
Message-ID: <20150618190434.GA3454@salvia>
References: <1434417013.27504.161.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150617170815.GF31987@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150617170815.GF31987@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 17, 2015 at 07:08:15PM +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Let's force a 16 bytes alignment on xt_counter percpu allocations,
> > so that bytes and packets sit in same cache line.
> > 
> > xt_counter being exported to user space, we cannot add __align(16) on
> > the structure itself.
> 
> Sorry, I was away.  Looks great.
> 
> Acked-by: Florian Westphal <fw@strlen.de>

Applied, thanks Eric and Florian !

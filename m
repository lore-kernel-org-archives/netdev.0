From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next] netfilter: xt_hashlimit: perform garbage
 collection from process context
Date: Thu, 24 Jul 2014 10:27:44 +0200
Message-ID: <20140724082744.GA18404@breakpoint.cc>
References: <1406176610.3363.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1406176610.3363.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> xt_hashlimit cannot be used with large hash tables, because garbage
> collector is run from a timer. If table is really big, its possible
> to hold cpu for more than 500 msec, which is unacceptable.
> 
> Switch to a work queue, and use proper scheduling points to remove
> latencies spikes.
> 
> Later, we also could switch to a smoother garbage collection done
> at lookup time, one bucket at a time...
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Reviewed-by: Florian Westphal <fw@strlen.de>

Thanks Eric!

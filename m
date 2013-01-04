From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: xt_recent: avoid high order page allocations
Date: Fri, 4 Jan 2013 20:23:16 +0100
Message-ID: <20130104192316.GA17714@1984>
References: <1357287519.1678.70.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Miroslav Kratochvil <exa.exa@gmail.com>,
	h.reindl@thelounge.net, Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1357287519.1678.70.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 04, 2013 at 12:18:39AM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> xt_recent can try high order page allocations and this can fail.
> 
> iptables: page allocation failure: order:9, mode:0xc0d0
> 
> It also wastes about half the allocated space because of kmalloc()
> power-of-two roundups and struct recent_table layout.
> 
> Use vmalloc() instead to save space and be less prone to allocation
> errors when memory is fragmented.

Applied, thanks Eric!

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] x_table: align per cpu xt_counter
Date: Thu, 18 Jun 2015 03:43:26 -0700 (PDT)
Message-ID: <20150618.034326.1579688535859905135.davem@davemloft.net>
References: <1434417013.27504.161.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434417013.27504.161.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 15 Jun 2015 18:10:13 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Let's force a 16 bytes alignment on xt_counter percpu allocations,
> so that bytes and packets sit in same cache line.
> 
> xt_counter being exported to user space, we cannot add __align(16) on
> the structure itself.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Florian Westphal <fw@strlen.de>

Pablo, I assume you will take this.

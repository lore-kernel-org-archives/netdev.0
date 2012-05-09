From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: remove two dropwatch false
 positives
Date: Wed, 9 May 2012 13:36:47 +0200
Message-ID: <20120509113647.GA23243@1984>
References: <1335942790.22133.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1335942790.22133.55.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2012 at 09:13:10AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> After skb_copy_expand() call, we want to switch skbs without dropping
> original one. Call consume_skb() to avoid drop_monitor sending a drop
> event.

We have removed ip_queue in 3.5. That's why I cannot take this patch.

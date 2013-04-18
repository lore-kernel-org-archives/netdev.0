From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/14]: netlink: memory mapped I/O
Date: Thu, 18 Apr 2013 07:57:32 -0700
Message-ID: <1366297052.3205.49.camel@edumazet-glaptop>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
	 <20130417194046.GF1408@breakpoint.cc>
	 <20130418102738.GA25166@macbook.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20130418102738.GA25166@macbook.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-18 at 12:27 +0200, Patrick McHardy wrote:

> No need to be sorry :) The use cases only partially overlap, the zero copy
> (actually single copy, just like mmaped netlink) requires drivers to generate
> fragmented skbs, while the mmaped netlink code works in all cases.

In fact all NIC drivers provides suitable skb in their RX path, as
skb->head is now a fragment too. 

So the 'zero copy' code should work for all drivers.

It might be possible to do the same in transmit path, if needed.



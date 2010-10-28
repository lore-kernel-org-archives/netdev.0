From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] conntrack: allow nf_ct_alloc_hashtable() to get highmem
 pages
Date: Thu, 28 Oct 2010 12:36:24 +0200
Message-ID: <4CC95228.9030808@trash.net>
References: <1288170555.2709.63.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1288170555.2709.63.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27.10.2010 11:09, Eric Dumazet wrote:
> commit ea781f197d6a8 (use SLAB_DESTROY_BY_RCU and get rid of call_rcu())
> did a mistake in __vmalloc() call in nf_ct_alloc_hashtable().
> 
> I forgot to add __GFP_HIGHMEM, so pages were taken from LOWMEM only.

Applied, thanks. I'll also pass this to -stable.

From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Save frag_max_size between PRE_ROUTING and POST_ROUTING
Date: Tue, 07 Oct 2014 15:13:10 -0400 (EDT)
Message-ID: <20141007.151310.1935755900721864640.davem@davemloft.net>
References: <20141004180647.GB1241@breakpoint.cc>
	<20141005035343.GA13696@gondor.apana.org.au>
	<20141005040022.GA14118@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org, bsd@redhat.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20141005040022.GA14118@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 5 Oct 2014 12:00:22 +0800

> bridge: Save frag_max_size between PRE_ROUTING and POST_ROUTING
> 
> As we may defragment the packet in IPv4 PRE_ROUTING and refragment
> it after POST_ROUTING we should save the value of frag_max_size.
> 
> This is still very wrong as the bridge is supposed to leave the
> packets intact, meaning that the right thing to do is to use the
> original frag_list for fragmentation.
> 
> Unfortunately we don't currently guarantee that the frag_list is
> left untouched throughout netfilter so until this changes this is
> the best we can do.
> 
> There is also a spot in FORWARD where it appears that we can
> forward a packet without going through fragmentation, mark it
> so that we can fix it later.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv6: use skb coalescing in reassembly
Date: Mon, 21 May 2012 07:37:43 +0200
Message-ID: <1337578663.3361.10.camel@edumazet-glaptop>
References: <1337432555.7029.196.camel@edumazet-glaptop>
	 <20120519.183556.1085711138074171029.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34983 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab2EUFhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 01:37:47 -0400
Received: by weyu7 with SMTP id u7so2941254wey.19
        for <netdev@vger.kernel.org>; Sun, 20 May 2012 22:37:46 -0700 (PDT)
In-Reply-To: <20120519.183556.1085711138074171029.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-05-19 at 18:35 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 19 May 2012 15:02:35 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > ip6_frag_reasm() can use skb_try_coalesce() to build optimized skb,
> > reducing memory used by them (truesize), and reducing number of cache
> > line misses and overhead for the consumer.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> Applied.

I'll do the same for net/ipv6/netfilter/nf_conntrack_reasm.c today.

Thanks

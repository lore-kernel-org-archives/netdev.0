From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/17] netvm: Propagate page->pfmemalloc to skb
Date: Thu, 17 May 2012 16:12:52 -0400 (EDT)
Message-ID: <20120517.161252.896110368946490093.davem@davemloft.net>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
	<1337266231-8031-12-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl,
        michaelc@cs.wisc.edu, emunson@mgebm.net
To: mgorman@suse.de
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1337266231-8031-12-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 17 May 2012 15:50:25 +0100

> The skb->pfmemalloc flag gets set to true iff during the slab
> allocation of data in __alloc_skb that the the PFMEMALLOC reserves
> were used. If the packet is fragmented, it is possible that pages
> will be allocated from the PFMEMALLOC reserve without propagating
> this information to the skb. This patch propagates page->pfmemalloc
> from pages allocated for fragments to the skb.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

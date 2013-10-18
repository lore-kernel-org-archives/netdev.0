From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: refactor sk_page_frag_refill()
Date: Fri, 18 Oct 2013 00:09:14 -0400 (EDT)
Message-ID: <20131018.000914.512438003196100861.davem@davemloft.net>
References: <1381623952.3392.25.camel@edumazet-glaptop.roam.corp.google.com>
	<1381639591.3392.31.camel@edumazet-glaptop.roam.corp.google.com>
	<1382052427.3284.3.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, dborkman@redhat.com, netdev@vger.kernel.org,
	ffusco@redhat.com, ycheng@google.com, ncardwell@google.com,
	digitaleric@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab3JREJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 00:09:16 -0400
In-Reply-To: <1382052427.3284.3.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 Oct 2013 16:27:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While working on virtio_net new allocation strategy to increase
> payload/truesize ratio, we found that refactoring sk_page_frag_refill()
> was needed.
> 
> This patch splits sk_page_frag_refill() into two parts, adding
> skb_page_frag_refill() which can be used without a socket.
> 
> While we are at it, add a minimum frag size of 32 for
> sk_page_frag_refill()
> 
> Michael will either use netdev_alloc_frag() from softirq context,
> or skb_page_frag_refill() from process context in refill_work()
>  (GFP_KERNEL allocations)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

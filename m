From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: mip6: fix mip6_mh_filter()
Date: Tue, 25 Sep 2012 16:05:47 -0400 (EDT)
Message-ID: <20120925.160547.1085599990285814524.davem@davemloft.net>
References: <1348603288.26828.3398.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454Ab2IYUFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 16:05:51 -0400
In-Reply-To: <1348603288.26828.3398.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Sep 2012 22:01:28 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> mip6_mh_filter() should not modify its input, or else its caller
> would need to recompute ipv6_hdr() if skb->head is reallocated.
> 
> Use skb_header_pointer() instead of pskb_may_pull()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.

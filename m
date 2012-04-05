From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove k{un}map_skb_frag()
Date: Thu, 05 Apr 2012 05:41:23 -0400 (EDT)
Message-ID: <20120405.054123.180053279559392181.davem@davemloft.net>
References: <1333618515.6309.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab2DEJl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 05:41:26 -0400
In-Reply-To: <1333618515.6309.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Apr 2012 11:35:15 +0200

> Since commit 3e4d3af501 (mm: stack based kmap_atomic()) we dont have to
> disable BH anymore while mapping skb frags.
> 
> We can remove  kmap_skb_frag() / kunmap_skb_frag() helpers and use
> kmap_atomic() / kunmap_atomic()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

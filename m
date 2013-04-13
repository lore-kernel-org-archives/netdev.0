From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: tcp_tso_segment() small optimization
Date: Sat, 13 Apr 2013 16:56:16 -0400 (EDT)
Message-ID: <20130413.165616.605528316971055596.davem@davemloft.net>
References: <1365858859.4459.94.camel@edumazet-glaptop>
	<1365859328.4459.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab3DMU4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 16:56:18 -0400
In-Reply-To: <1365859328.4459.97.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 13 Apr 2013 06:22:08 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We can move th->check computation out of the loop, as compiler
> doesn't know each skb initially share same tcp headers after
> skb_segment()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks!

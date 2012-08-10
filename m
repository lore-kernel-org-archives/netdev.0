From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix ip_send_skb()
Date: Fri, 10 Aug 2012 14:09:27 -0700 (PDT)
Message-ID: <20120810.140927.907727160541183930.davem@davemloft.net>
References: <1344601367.31104.2672.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853Ab2HJVJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2012 17:09:27 -0400
In-Reply-To: <1344601367.31104.2672.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Aug 2012 14:22:47 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ip_send_skb() can send orphaned skb, so we must pass the net pointer to
> avoid possible NULL dereference in error path.
> 
> Bug added by commit 3a7c384ffd57 (ipv4: tcp: unicast_sock should not
> land outside of TCP stack)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

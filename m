From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: raw: fix icmp_filter()
Date: Sat, 22 Sep 2012 15:35:45 -0400 (EDT)
Message-ID: <20120922.153545.528940879379972527.davem@davemloft.net>
References: <1348308509.2669.1105.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751903Ab2IVTfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 15:35:46 -0400
In-Reply-To: <1348308509.2669.1105.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Sep 2012 12:08:29 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> icmp_filter() should not modify its input, or else its caller
> would need to recompute ip_hdr() if skb->head is reallocated.
> 
> Use skb_header_pointer() instead of pskb_may_pull() and
> change the prototype to make clear both sk and skb are const.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.

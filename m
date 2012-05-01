From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netem: fix possible skb leak
Date: Tue, 01 May 2012 13:41:13 -0400 (EDT)
Message-ID: <20120501.134113.1208540329806372331.davem@davemloft.net>
References: <1335726502.3897.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@osdl.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754405Ab2EARlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 13:41:17 -0400
In-Reply-To: <1335726502.3897.8.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 29 Apr 2012 21:08:22 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> skb_checksum_help(skb) can return an error, we must free skb in this
> case. qdisc_drop(skb, sch) can also be feeded with a NULL skb (if
> skb_unshare() failed), so lets use this generic helper.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce __skb_header_release()
Date: Fri, 26 Sep 2014 15:40:21 -0400 (EDT)
Message-ID: <20140926.154021.663234155981881132.davem@davemloft.net>
References: <1411428572.26859.165.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755047AbaIZTkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 15:40:23 -0400
In-Reply-To: <1411428572.26859.165.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Sep 2014 16:29:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While profiling TCP stack, I noticed one useless atomic operation
> in tcp_sendmsg(), caused by skb_header_release().
> 
> It turns out all current skb_header_release() users have a fresh skb,
> that no other user can see, so we can avoid one atomic operation.
> 
> Introduce __skb_header_release() to clearly document this.
> 
> This gave me a 1.5 % improvement on TCP_RR workload.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks great, applied, thanks!

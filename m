From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: support encapsulated ipv6 TSO
Date: Thu, 15 Oct 2015 23:30:29 -0700 (PDT)
Message-ID: <20151015.233029.965588206994493848.davem@davemloft.net>
References: <1444926131.25595.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51237 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbbJPGOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 02:14:20 -0400
In-Reply-To: <1444926131.25595.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Oct 2015 09:22:11 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If using a sixtofour device on top of a bonding device,
> skb segmentation of TCP traffic is done right before calling
> bonding xmit, because bonding only enables TSO for IPv4.
> 
> This patch improves single flow performance by about 120 % on my hosts,
> because segmentation is deferred right before calling slave xmit.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

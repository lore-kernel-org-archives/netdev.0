From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_unix: fix bug on large send()
Date: Sun, 11 Aug 2013 22:02:49 -0700 (PDT)
Message-ID: <20130811.220249.559351679802720229.davem@davemloft.net>
References: <1376231553.3291.0.camel@edumazet-glaptop>
	<20130811143715.GA3699@order.stressinduktion.org>
	<1376283288.3338.7.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, rientjes@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3HLE51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 00:57:27 -0400
In-Reply-To: <1376283288.3338.7.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 11 Aug 2013 21:54:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit e370a723632 ("af_unix: improve STREAM behavior with fragmented
> memory") added a bug on large send() because the
> skb_copy_datagram_from_iovec() call always start from the beginning
> of iovec.
> 
> We must instead use the @sent variable to properly skip the
> already processed part.
> 
> Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

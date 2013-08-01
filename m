From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add a temporary sanity check in
 skb_orphan()
Date: Thu, 01 Aug 2013 12:49:41 -0700 (PDT)
Message-ID: <20130801.124941.615533263470839691.davem@davemloft.net>
References: <1375382588.10515.181.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52986 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817Ab3HATto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 15:49:44 -0400
In-Reply-To: <1375382588.10515.181.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 01 Aug 2013 11:43:08 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> David suggested to add a BUG_ON() to catch if some layer
> sets skb->sk pointer without a corresponding destructor.
> 
> As skb can sit in a queue, it's mandatory to make sure the
> socket cannot disappear, and it's usually done by taking a
> reference on the socket, then releasing it from the skb
> destructor.
> 
> This patch is a follow-up to commit c34a761231b5
> ("net: skb_orphan() changes") and will be reverted after
> catching all possible offenders if any.
> 
> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.

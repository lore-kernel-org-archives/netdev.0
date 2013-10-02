From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: do not call sock_put() on TIMEWAIT sockets
Date: Wed, 02 Oct 2013 17:06:25 -0400 (EDT)
Message-ID: <20131002.170625.1002977193577152979.davem@davemloft.net>
References: <1380686651.19002.64.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385Ab3JBVGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 17:06:33 -0400
In-Reply-To: <1380686651.19002.64.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Oct 2013 21:04:11 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 3ab5aee7fe84 ("net: Convert TCP & DCCP hash tables to use RCU /
> hlist_nulls") incorrectly used sock_put() on TIMEWAIT sockets.
> 
> We should instead use inet_twsk_put()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Ugh, applied and queued up for -stable, thanks Eric!

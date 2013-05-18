From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: use ipv6_dup_options() from
 ip6_append_data()
Date: Sat, 18 May 2013 12:57:45 -0700 (PDT)
Message-ID: <20130518.125745.1801641505342864639.davem@davemloft.net>
References: <1368750452.3301.74.camel@edumazet-glaptop>
	<20130517135804.GA16069@gondor.apana.org.au>
	<1368802393.3301.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58819 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab3ERT5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 15:57:46 -0400
In-Reply-To: <1368802393.3301.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 May 2013 07:53:13 -0700

> [PATCH] ipv6: fix possible crashes in ip6_cork_release()
> 
> commit 0178b695fd6b4 ("ipv6: Copy cork options in ip6_append_data")
> added some code duplication and bad error recovery, leading to potential
> crash in ip6_cork_release() as kfree() could be called with garbage.
> 
> use kzalloc() to make sure this wont happen.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.

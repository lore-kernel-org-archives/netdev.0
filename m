From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix possible deadlock in sum_frag_mem_limit
Date: Fri, 22 Feb 2013 15:14:20 -0500 (EST)
Message-ID: <20130222.151420.1087260069127274940.davem@davemloft.net>
References: <20130222171343.GB27619@redhat.com>
	<1361555015.3683.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46855 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757276Ab3BVUOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 15:14:23 -0500
In-Reply-To: <1361555015.3683.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 22 Feb 2013 09:43:35 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dave Jones reported a lockdep splat occurring in IP defrag code.
> 
> commit 6d7b857d541ecd1d (net: use lib/percpu_counter API for
> fragmentation mem accounting) added a possible deadlock.
> 
> Because percpu_counter_sum_positive() needs to acquire
> a lock that can be used from softirq, we need to disable BH
> in sum_frag_mem_limit()
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>

Applied.

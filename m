From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp/dccp: better use of ephemeral ports
Date: Thu, 11 Feb 2016 11:48:25 -0500 (EST)
Message-ID: <20160211.114825.2144275138787010650.davem@davemloft.net>
References: <1454724538-13556-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbcBKQs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 11:48:29 -0500
In-Reply-To: <1454724538-13556-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Fri,  5 Feb 2016 18:08:56 -0800

> Big servers have bloated bind table, making very hard to succeed
> ephemeral port allocations, without special containers/namespace tricks.
> 
> This patch series extends the strategy added in commit 07f4c90062f8 
> ("tcp/dccp: try to not exhaust ip_local_port_range in connect()").
> 
> Since ports used by connect() are much likely to be shared among them,
> we give a hint to both bind() and connect() to keep the crowds separated
> if possible.
> 
> Of course, if on a specific host an application needs to allocate ~30000
> ports using bind(), it will still be able to do so. Same for ~30000 connect()
> to a unique 2-tuple (dst addr, dst port)
> 
> New implemetation is also more friendly to softirqs and reschedules.

I'm getting rejects on the second patch, please respin and repost.

Thanks Eric.

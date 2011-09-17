From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: remove one indirection level in
 tcp_md5sig_pool
Date: Sat, 17 Sep 2011 01:15:58 -0400 (EDT)
Message-ID: <20110917.011558.942032708010034196.davem@davemloft.net>
References: <1315895317.2556.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab1IQFQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 01:16:01 -0400
In-Reply-To: <1315895317.2556.28.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Sep 2011 08:28:37 +0200

> tcp_md5sig_pool is currently an 'array' (a percpu object) of pointers to
> struct tcp_md5sig_pool. Only the pointers are NUMA aware, but objects
> themselves are all allocated on a single node.
> 
> Remove this extra indirection to get proper percpu memory (NUMA aware)
> and make code simpler.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.

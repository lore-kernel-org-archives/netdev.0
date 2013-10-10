From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use ACCESS_ONCE() in
 tcp_update_pacing_rate()
Date: Thu, 10 Oct 2013 00:18:22 -0400 (EDT)
Message-ID: <20131010.001822.1347842044840028502.davem@davemloft.net>
References: <1381364092.4971.57.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab3JJESX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 00:18:23 -0400
In-Reply-To: <1381364092.4971.57.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 Oct 2013 17:14:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> sk_pacing_rate is read by sch_fq packet scheduler at any time,
> with no synchronization, so make sure we update it in a
> sensible way. ACCESS_ONCE() is how we instruct compiler
> to not do stupid things, like using the memory location
> as a temporary variable.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Also applied, thanks a lot.

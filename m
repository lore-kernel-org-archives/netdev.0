From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix a lockdep splat
Date: Mon, 08 Feb 2016 10:46:21 -0500 (EST)
Message-ID: <20160208.104621.2282889752696139407.davem@davemloft.net>
References: <20160202195933.GA6302@codemonkey.org.uk>
	<1454464501.7627.210.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754270AbcBHPq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 10:46:26 -0500
In-Reply-To: <1454464501.7627.210.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 02 Feb 2016 17:55:01 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Silence lockdep false positive about rcu_dereference() being
> used in the wrong context.
> 
> First one should use rcu_dereference_protected() as we own the spinlock.
> 
> Second one should be a normal assignation, as no barrier is needed.
> 
> Fixes: 18367681a10bd ("ipv6 flowlabel: Convert np->ipv6_fl_list to RCU.")
> Reported-by: Dave Jones <davej@codemonkey.org.uk>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.

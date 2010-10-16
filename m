From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib: remove a useless synchronize_rcu() call
Date: Sat, 16 Oct 2010 11:55:51 -0700 (PDT)
Message-ID: <20101016.115551.59659683.davem@davemloft.net>
References: <1286980984.3876.679.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54727
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753879Ab0JPSz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:55:28 -0400
In-Reply-To: <1286980984.3876.679.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 13 Oct 2010 16:43:04 +0200

> fib_nl_delrule() calls synchronize_rcu() for no apparent reason,
> while rtnl is held.
> 
> I suspect it was done to avoid an atomic_inc_not_zero() in
> fib_rules_lookup(), which commit 7fa7cb7109d07 added anyway.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

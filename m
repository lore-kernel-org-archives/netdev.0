From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fib: fix incorrect call_rcu_bh()
Date: Wed, 08 Aug 2012 15:57:58 -0700 (PDT)
Message-ID: <20120808.155758.194423138369923978.davem@davemloft.net>
References: <1344336431.28967.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757683Ab2HHW56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2012 18:57:58 -0400
In-Reply-To: <1344336431.28967.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Aug 2012 12:47:11 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> After IP route cache removal, I believe rcu_bh() has very little use and
> we should remove this RCU variant, since it adds some cycles in fast
> path.
> 
> Anyway, the call_rcu_bh() use in fib_true is obviously wrong, since
> some users only assert rcu_read_lock().
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Applied, thanks.

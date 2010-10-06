From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib: RCU conversion of fib_lookup()
Date: Tue, 05 Oct 2010 20:40:49 -0700 (PDT)
Message-ID: <20101005.204049.48504010.davem@davemloft.net>
References: <1286311296.2593.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57986
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756934Ab0JFDk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 23:40:27 -0400
In-Reply-To: <1286311296.2593.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Oct 2010 22:41:36 +0200

> fib_lookup() converted to be called in RCU protected context, no
> reference taken and released on a contended cache line (fib_clntref)
> 
> fib_table_lookup() and fib_semantic_match() get an additional parameter.
> 
> struct fib_info gets an rcu_head field, and is freed after an rcu grace
> period.
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I love it!

Applied, thanks!

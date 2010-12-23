From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.36.2 - loop on read /proc/net/tcp
Date: Thu, 23 Dec 2010 09:33:11 -0800 (PST)
Message-ID: <20101223.093311.226768777.davem@davemloft.net>
References: <20101222134343.GC19998@beaver.vrungel.ru>
	<1293080846.2679.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: renton@renton.name, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293080846.2679.41.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Dec 2010 06:07:26 +0100

> [PATCH] tcp: fix listening_get_next()
> 
> Alexey Vlasov found /proc/net/tcp could sometime loop and display
> millions of sockets in LISTEN state.
> 
> In 2.6.29, when we converted TCP hash tables to RCU, we left two
> sk_next() calls in listening_get_next().
> 
> We must instead use sk_nulls_next() to properly detect an end of chain.
> 
> Reported-by: Alexey Vlasov <renton@renton.name>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.

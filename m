From: David Miller <davem@davemloft.net>
Subject: Re: Regression, bisected: WARNING spam with ipsec since 2.6.35
Date: Thu, 16 Sep 2010 21:46:29 -0700 (PDT)
Message-ID: <20100916.214629.236248452.davem@davemloft.net>
References: <20100916213138.GA6605@elliptictech.com>
	<1284676070.4784.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbowler@elliptictech.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284676070.4784.25.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 17 Sep 2010 00:27:50 +0200

> [PATCH] xfrm: dont assume rcu_read_lock in xfrm_output_one()
> 
> ip_local_out() is called with rcu_read_lock() held from ip_queue_xmit()
> but not from other call sites.
> 
> Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

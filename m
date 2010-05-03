From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: if6_get_next() fix
Date: Mon, 03 May 2010 15:17:25 -0700 (PDT)
Message-ID: <20100503.151725.94856059.davem@davemloft.net>
References: <1272917635.2407.106.camel@edumazet-laptop>
	<20100503.132442.200112018.davem@davemloft.net>
	<1272919814.2407.149.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, shemminger@vyatta.com,
	Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org,
	peterz@infradead.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1272919814.2407.149.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 May 2010 22:50:14 +0200

> Paul, David, here the patch I was thinking about :
> 
> Feel free to split it in two parts if you like, I am too tired and must
> sleep now ;)
 ...
> [PATCH net-next-2.6] net: rcu fixes
> 
> Add hlist_for_each_entry_rcu_bh() and
> hlist_for_each_entry_continue_rcu_bh() macros, and use them in
> ipv6_get_ifaddr(), if6_get_first() and if6_get_next() to fix lockdeps
> warnings.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Paul, let me know if you want to handle these seperately (one commit
in your tree for the rculist.h bit and one for the ipv6 change) or to
put it all at once into net-next-2.6, I'm happy either way.

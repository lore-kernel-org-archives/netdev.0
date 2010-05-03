From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: if6_get_next() fix
Date: Mon, 03 May 2010 15:54:11 -0700 (PDT)
Message-ID: <20100503.155411.112816416.davem@davemloft.net>
References: <20100503.132442.200112018.davem@davemloft.net>
	<1272919814.2407.149.camel@edumazet-laptop>
	<20100503225229.GO2597@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org,
	peterz@infradead.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100503225229.GO2597@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Mon, 3 May 2010 15:52:29 -0700

> On Mon, May 03, 2010 at 10:50:14PM +0200, Eric Dumazet wrote:
>> Paul, David, here the patch I was thinking about :
>> 
>> Feel free to split it in two parts if you like, I am too tired and must
>> sleep now ;)
>> 
>> Thanks
>> 
>> [PATCH net-next-2.6] net: rcu fixes
>> 
>> Add hlist_for_each_entry_rcu_bh() and
>> hlist_for_each_entry_continue_rcu_bh() macros, and use them in
>> ipv6_get_ifaddr(), if6_get_first() and if6_get_next() to fix lockdeps
>> warnings.
> 
> Looks good!!!
> 
> It will collide with Arnd's sparse-based changes, but that will be
> easy to fix, so no problem.
> 
> Reviewed-by: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

Applied, thanks!

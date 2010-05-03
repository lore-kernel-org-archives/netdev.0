From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next-2.6] net: if6_get_next() fix
Date: Mon, 3 May 2010 15:48:19 -0700
Message-ID: <20100503224819.GN2597@linux.vnet.ibm.com>
References: <1272917635.2407.106.camel@edumazet-laptop>
 <20100503.132442.200112018.davem@davemloft.net>
 <1272919814.2407.149.camel@edumazet-laptop>
 <20100503.151725.94856059.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com,
	Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org,
	peterz@infradead.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100503.151725.94856059.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 03, 2010 at 03:17:25PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 03 May 2010 22:50:14 +0200
> 
> > Paul, David, here the patch I was thinking about :
> > 
> > Feel free to split it in two parts if you like, I am too tired and must
> > sleep now ;)
>  ...
> > [PATCH net-next-2.6] net: rcu fixes
> > 
> > Add hlist_for_each_entry_rcu_bh() and
> > hlist_for_each_entry_continue_rcu_bh() macros, and use them in
> > ipv6_get_ifaddr(), if6_get_first() and if6_get_next() to fix lockdeps
> > warnings.
> > 
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Paul, let me know if you want to handle these seperately (one commit
> in your tree for the rculist.h bit and one for the ipv6 change) or to
> put it all at once into net-next-2.6, I'm happy either way.

These changes look pretty closely integrated, so it is probably better
if they go up your tree with the related networking changes.  I will
take a look at them.

							Thanx, Paul

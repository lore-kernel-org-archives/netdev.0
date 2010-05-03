From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: if6_get_next() fix
Date: Mon, 03 May 2010 22:13:55 +0200
Message-ID: <1272917635.2407.106.camel@edumazet-laptop>
References: <1272903293.2226.50.camel@edumazet-laptop>
	 <20100503181629.GJ2597@linux.vnet.ibm.com>
	 <1272916007.2407.75.camel@edumazet-laptop>
	 <20100503.130902.172620141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, shemminger@vyatta.com,
	Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org,
	peterz@infradead.org, kaber@trash.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100503.130902.172620141.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 mai 2010 =C3=A0 13:09 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 03 May 2010 21:46:47 +0200
>=20
> > Then, net-next-2.6 doesnt yet have your commit Paul to relax
> > hlist_for_each_entry_rcu(), so its a bit difficult to continue the =
work.
>=20
> Is that in Linus's tree yet?  If it propagates there I can make it
> propagate to net-next-2.6, you just have to tell me you need it.


Hmm, it seems it's already in net-next-2.6, sorry for the confusion.

commit 3120438ad68601f341e61e7cb1323b0e1a6ca367
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Mon Feb 22 17:04:48 2010 -0800

    rcu: Disable lockdep checking in RCU list-traversal primitives
   =20
    The theory is that use of bare rcu_dereference() is more prone
    to error than use of the RCU list-traversal primitives.
    Therefore, disable lockdep RCU read-side critical-section
    checking in these primitives for the time being.  Once all of
    the rcu_dereference() uses have been dealt with, it may be time
    to re-enable lockdep checking for the RCU list-traversal
    primitives.
   =20


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

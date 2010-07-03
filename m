From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL rcu/urgent] revert ->br_port fix, obsoleted by netdev
 commit
Date: Sat, 3 Jul 2010 15:11:41 +0200
Message-ID: <20100703131140.GD26067@elte.hu>
References: <20100701215655.GA24450@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, arnd@arndb.de, davem@davemloft.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, sfr@canb.auug.org.au
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100701215655.GA24450@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> Hello, Ingo,
> 
> This pull request reverts commit 81bdf5bd, which has been obsoleted
> by commit f350a0a87374 from the netdev folks.  This conflict was caught
> in the -next tree.
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-2.6-rcu.git rcu/next
> 
> 							Thanx, Paul
> 
> ------------------>
> Paul E. McKenney (1):
>       Revert "net: Make accesses to ->br_port safe for sparse RCU"
> 
>  include/linux/if_bridge.h           |    3 ---
>  net/bridge/br_fdb.c                 |    2 +-
>  net/bridge/br_private.h             |    5 -----
>  net/bridge/netfilter/ebt_redirect.c |    2 +-
>  net/bridge/netfilter/ebt_ulog.c     |    4 ++--
>  net/bridge/netfilter/ebtables.c     |    4 ++--
>  net/netfilter/nfnetlink_log.c       |    4 ++--
>  net/netfilter/nfnetlink_queue.c     |    4 ++--
>  8 files changed, 10 insertions(+), 18 deletions(-)

Pulled, thanks a lot Paul!

	Ingo

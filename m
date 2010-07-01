From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [GIT PULL rcu/urgent] revert ->br_port fix, obsoleted by netdev
 commit
Date: Thu, 1 Jul 2010 14:56:55 -0700
Message-ID: <20100701215655.GA24450@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, arnd@arndb.de, davem@davemloft.net,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, sfr@canb.auug.org.au
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57607 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933477Ab0GAV46 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 17:56:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Ingo,

This pull request reverts commit 81bdf5bd, which has been obsoleted
by commit f350a0a87374 from the netdev folks.  This conflict was caught
in the -next tree.

  git://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-2.6-rcu.git rcu/next

							Thanx, Paul

------------------>
Paul E. McKenney (1):
      Revert "net: Make accesses to ->br_port safe for sparse RCU"

 include/linux/if_bridge.h           |    3 ---
 net/bridge/br_fdb.c                 |    2 +-
 net/bridge/br_private.h             |    5 -----
 net/bridge/netfilter/ebt_redirect.c |    2 +-
 net/bridge/netfilter/ebt_ulog.c     |    4 ++--
 net/bridge/netfilter/ebtables.c     |    4 ++--
 net/netfilter/nfnetlink_log.c       |    4 ++--
 net/netfilter/nfnetlink_queue.c     |    4 ++--
 8 files changed, 10 insertions(+), 18 deletions(-)

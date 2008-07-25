From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 25 Jul 2008 16:55:39 -0700 (PDT)
Message-ID: <20080725.165539.91586849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42026
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752915AbYGYXzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 19:55:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A fix for a lockdep problem reported by Ingo, and a cure
for order-5 page allocations that can be triggered by
IPCOMP decompression from Herbert Xu.

Please pull, thanks a lot!

The following changes since commit f867e6af94239a04ec23aeec2fcda5aa58e41db7:
  Jarek Poplawski (1):
        pkt_sched: sch_sfq: dump a real number of flows

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      pkt_sched: Fix locking in shutdown_scheduler_queue()

Herbert Xu (2):
      ipsec: ipcomp - Merge IPComp implementations
      ipsec: ipcomp - Decompress into frags if necessary

 include/net/ipcomp.h    |    6 +
 net/ipv4/Kconfig        |    4 +-
 net/ipv4/ipcomp.c       |  315 +-------------------------------------
 net/ipv6/Kconfig        |    4 +-
 net/ipv6/ipcomp6.c      |  298 +-----------------------------------
 net/sched/sch_generic.c |    4 +-
 net/xfrm/Kconfig        |    6 +
 net/xfrm/Makefile       |    1 +
 net/xfrm/xfrm_ipcomp.c  |  385 +++++++++++++++++++++++++++++++++++++++++++++++
 9 files changed, 415 insertions(+), 608 deletions(-)
 create mode 100644 net/xfrm/xfrm_ipcomp.c

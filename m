From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 21 May 2011 02:20:27 -0400 (EDT)
Message-ID: <20110521.022027.978642556111515425.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I wanted to push this quickly to fix the build fallout:

1) SCTP build failed due to intersection of two commits
   happening in two different trees.

2) ipv6 RTA_PREFSRC support doesn't propagate the prefsrc
   value into new copied routes.

3) garp can use kfree_rcu() too

Please pull, thanks a lot!

The following changes since commit 557eed603159b4e007c57d97fad1333ecebd3c2e:

  Merge branch 'upstream-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/libata-dev (2011-05-20 14:31:27 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      sctp: Fix build failure.

Eric Dumazet (1):
      garp: use kfree_rcu()

Florian Westphal (1):
      ipv6: copy prefsrc setting when copying route entry

 net/802/garp.c       |   20 ++------------------
 net/ipv6/route.c     |    1 +
 net/sctp/bind_addr.c |    2 +-
 3 files changed, 4 insertions(+), 19 deletions(-)

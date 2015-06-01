From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] Netfilter fix for net
Date: Mon,  1 Jun 2015 19:54:01 +0200
Message-ID: <1433181242-22768-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patch reverts the ebtables chunk that enforces counters that was
introduced in the recently applied d26e2c9ffa38 ('Revert "netfilter: ensure
number of counters is >0 in do_replace()"') since this breaks ebtables.

You can pull this change from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 9302d7bb0c5cd46be5706859301f18c137b2439f:

  sctp: Fix mangled IPv4 addresses on a IPv6 listening socket (2015-05-27 14:15:26 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to d26e2c9ffa385dd1b646f43c1397ba12af9ed431:

  Revert "netfilter: ensure number of counters is >0 in do_replace()" (2015-06-01 19:45:47 +0200)

----------------------------------------------------------------
Bernhard Thaler (1):
      Revert "netfilter: ensure number of counters is >0 in do_replace()"

 net/bridge/netfilter/ebtables.c |    4 ----
 1 file changed, 4 deletions(-)

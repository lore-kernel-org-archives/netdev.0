From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/03: netfilter fixes
Date: Wed,  8 Apr 2009 18:52:16 +0200 (MEST)
Message-ID: <20090408165212.6702.44171.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

the following patches fix three netfilter bugs:

- an incorrect dependency for the new LED target, added by myself to fix
  the compilation problem reported one or two weeks ago

- a fix for the ip6_tables "lock free counters" regression caused by a
  missing return statement

- a fix for a regression in .29, causing conntrack expectation refresh to
  create a new expectation instead of refreshing the existing one.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Please note that the git tree will bring in a merge commit of Linus'
tree from 2 days ago.

Thanks!


 include/net/netfilter/nf_conntrack_expect.h |    5 +++-
 net/ipv6/netfilter/ip6_tables.c             |    2 +
 net/netfilter/Kconfig                       |    2 +-
 net/netfilter/nf_conntrack_expect.c         |   30 +++++---------------------
 4 files changed, 13 insertions(+), 26 deletions(-)

Alex Riesen (1):
      netfilter: fix selection of "LED" target in netfilter

Eric Dumazet (1):
      netfilter: ip6tables regression fix

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix regression in expectation handling

From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/03: netfilter fixes
Date: Thu, 16 Jul 2009 14:26:44 +0200 (MEST)
Message-ID: <20090716122638.23343.77832.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following are two netfilter fixes for 2.6.31 and a MAINTAINERS update:

- a fix for the nf_conntrack_alloc() race from Eric
- a fix for incorrect invocation of nf_log_packet() in the new osf match
- a patch to add my netfilter git tree to MAINTAINERS

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git master

Thanks!


 Documentation/RCU/rculist_nulls.txt |    7 ++++++-
 MAINTAINERS                         |    1 +
 net/netfilter/nf_conntrack_core.c   |   21 ++++++++++++++++++---
 net/netfilter/xt_osf.c              |    5 +++--
 4 files changed, 28 insertions(+), 6 deletions(-)

Eric Dumazet (1):
      netfilter: nf_conntrack: nf_conntrack_alloc() fixes

Joe Perches (1):
      netfilter: add netfilter git to MAINTAINERS

Patrick McHardy (1):
      netfilter: xt_osf: fix nf_log_packet() arguments

From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] netfilter fixes for net
Date: Tue,  7 Jan 2014 23:13:37 +0100
Message-ID: <1389132819-9697-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains two patches:

* fix the IRC NAT helper which was broken when adding (incomplete) IPv6
  support, from Daniel Borkmann.

* Refine the previous bugtrap that Jesper added to catch problems for the
  usage of the sequence adjustment extension in IPVs in Dec 16th, it may
  spam messages in case of finding a real bug.

I know it's fairly late, so please let me know if you prefer that I pass
you these via net-next.

Thanks!

----------------------------------------------------------------

The following changes since commit f35f76ee76df008131bbe01a2297de0c55ee2297:

  xen-netback: Include header for vmalloc (2014-01-05 20:34:36 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to f2661adc0c134d890d84c32d7cb54a2b4d1f0a5f:

  netfilter: only warn once on wrong seqadj usage (2014-01-06 14:23:17 +0100)

----------------------------------------------------------------
Daniel Borkmann (1):
      netfilter: nf_nat: fix access to uninitialized buffer in IRC NAT helper

Jesper Dangaard Brouer (1):
      netfilter: only warn once on wrong seqadj usage

 net/netfilter/nf_conntrack_seqadj.c |    2 +-
 net/netfilter/nf_nat_irc.c          |   32 +++++++++++++++++++++++++++-----
 2 files changed, 28 insertions(+), 6 deletions(-)

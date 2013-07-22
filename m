From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter fixes for net (3.11-rc1)
Date: Mon, 22 Jul 2013 10:34:35 +0200
Message-ID: <1374482077-4547-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

* Fix potential NULL dereference in the socket match if revision 0
  is used, from Eric Dumazet.

* Fix missing expectation NAT initialization that results in dumping
  the NAT part via ctnetlink, thus leading to problems in expectation
  synchronization through conntrackd, from myself.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 63345b4794aef4ebe16502cfe35b02bc9822d763:

  Merge branch 'for_linus' of git://cavan.codon.org.uk/platform-drivers-x86 (2013-07-13 18:08:23 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to baf60efa585c78b269f0097288868a51ccc61f55:

  netfilter: xt_socket: fix broken v0 support (2013-07-15 11:15:21 +0200)

----------------------------------------------------------------
Eric Dumazet (1):
      netfilter: xt_socket: fix broken v0 support

Pablo Neira Ayuso (1):
      netfilter: ctnetlink: fix incorrect NAT expectation dumping

 net/netfilter/nf_conntrack_expect.c |    5 +++++
 net/netfilter/xt_socket.c           |   10 +++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)


Eric Dumazet (1):
  netfilter: xt_socket: fix broken v0 support

Pablo Neira Ayuso (1):
  netfilter: ctnetlink: fix incorrect NAT expectation dumping

 net/netfilter/nf_conntrack_expect.c |    5 +++++
 net/netfilter/xt_socket.c           |   10 +++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)

-- 
1.7.10.4


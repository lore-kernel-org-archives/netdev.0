From: pablo@netfilter.org
Subject: [PATCH 0/6] netfilter fixes for 3.3-rc6
Date: Tue,  6 Mar 2012 12:22:49 +0100
Message-ID: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains netfilter fixes for 3.3-rc6:

* one fix from Florian Westphal to fix vlan 802.1Q and netfilter bridging.

* one fix from Santosh Nayak to avoid leaking 3 bytes of data to
  user-space via ebtables.

* four fixes from myself, mostly for ctnetlink. Two of them are relative
  fixes to Santosh's patch (it contained one mistake) and another to
  previous Jozsef's patch.

You can pull this changes from:

git://1984.lsi.us.es/net master

Netfilter updates for net-next will follow once you pull this. I won't
delay, I guess there's no much remaining time to close the merge window.

Thanks!

Florian Westphal (1):
  bridge: netfilter: don't call iptables on vlan packets if sysctl is off

Pablo Neira Ayuso (4):
  netfilter: ctnetlink: remove incorrect spin_[un]lock_bh on NAT module autoload
  netfilter: ctnetlink: use GFP_ATOMIC in all allocations
  netfilter: bridge: fix wrong pointer dereference
  netfilter: nf_conntrack: fix early_drop with reliable event delivery

Santosh Nayak (1):
  netfilter: ebtables: fix wrong name length while copying to user-space

 net/bridge/br_netfilter.c            |   32 ++++++++++++++++++--------------
 net/bridge/netfilter/ebtables.c      |   16 +++++++++++++---
 net/netfilter/nf_conntrack_core.c    |    8 ++++++--
 net/netfilter/nf_conntrack_netlink.c |    7 ++-----
 4 files changed, 39 insertions(+), 24 deletions(-)

-- 
1.7.7.3


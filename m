From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter fixes for net-next
Date: Tue, 10 Mar 2015 16:46:19 +0100
Message-ID: <1426002381-20302-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37536 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753776AbbCJPmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 11:42:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following batch contains a couple of fixes to address some fallout
from the previous pull request, they are:

1) Address link problems in the bridge code after e5de75b. Fix it by
   using rcu hook to address to avoid ifdef pollution and hard
   dependency between bridge and br_netfilter.

2) Address sparse warnings in the netfilter reject code, patch from
   Florian Westphal.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 8ac467e837a24eb024177b4b01013d8e6764913a:

  net: bcmgenet: core changes for supporting multiple Rx queues (2015-03-09 22:51:56 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 1a4ba64d16a42c1b31d52b671accd7f9103e2626:

  netfilter: bridge: use rcu hook to resolve br_netfilter dependency (2015-03-10 15:03:02 +0100)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: fix sparse warnings in reject handling

Pablo Neira Ayuso (1):
      netfilter: bridge: use rcu hook to resolve br_netfilter dependency

 include/net/netfilter/ipv4/nf_reject.h   |    2 +-
 include/net/netfilter/ipv6/nf_reject.h   |    2 +-
 net/bridge/br_device.c                   |    7 ++++++-
 net/bridge/br_netfilter.c                |    9 +++++++--
 net/bridge/br_private.h                  |   10 +++++-----
 net/bridge/netfilter/nft_reject_bridge.c |    2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c      |    2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c      |    2 +-
 8 files changed, 23 insertions(+), 13 deletions(-)

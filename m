From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] nf_tables updates for net-next
Date: Mon,  4 Nov 2013 23:05:16 +0100
Message-ID: <1383602721-5728-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57681 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554Ab3KDWFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 17:05:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This batch contains fives nf_tables patches for your net-next tree,
they are:

* Fix possible use after free in the module removal path of the
  x_tables compatibility layer, from Dan Carpenter.

* Add filter chain type for the bridge family, from myself.

* Fix Kconfig dependencies of the nf_tables bridge family with
  the core, from myself.

* Fix sparse warnings in nft_nat, from Tomasz Bursztyka.

* Remove duplicated include in the IPv4 family support for nf_tables,
  from Wei Yongjun.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

Thanks!

----------------------------------------------------------------

The following changes since commit a5bb202b848c7962f942f81d93290a9ccdfb1a0f:

  netdev: inet_timewait_sock.h missing semi-colon when KMEMCHECK is enabled (2013-10-17 15:56:53 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nftables.git master

for you to fetch changes up to c359c4157cf0d852387aff2f2d83fef039aadc2c:

  netfilter: nft_compat: use _safe version of list_for_each (2013-11-04 22:58:30 +0100)

----------------------------------------------------------------
Dan Carpenter (1):
      netfilter: nft_compat: use _safe version of list_for_each

Pablo Neira Ayuso (2):
      netfilter: bridge: fix nf_tables bridge dependencies with main core
      netfilter: bridge: nf_tables: add filter chain type

Tomasz Bursztyka (1):
      netfilter: nft_nat: Fix endianness issue reported by sparse

Wei Yongjun (1):
      netfilter: nf_tables: remove duplicated include from nf_tables_ipv4.c

 net/bridge/netfilter/Kconfig            |    1 +
 net/bridge/netfilter/nf_tables_bridge.c |   41 +++++++++++++++++++++++++++++--
 net/ipv4/netfilter/nf_tables_ipv4.c     |    1 -
 net/netfilter/nft_compat.c              |    8 +++---
 net/netfilter/nft_nat.c                 |   12 ++++++---
 5 files changed, 52 insertions(+), 11 deletions(-)

From: pablo@netfilter.org
Subject: [PATCH 0/4] netfilter fixes for 3.4-rc7
Date: Mon, 14 May 2012 13:46:59 +0200
Message-ID: <1336996023-20249-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35154 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755747Ab2ENLr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 07:47:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains several fixes for Netfilter 3.4-rc7:

* One fix for possible timeout overflow for ipset, from Jozsef
  Kadlecsik.

* One fix to ensure that hash size is correct, again for ipset
  from Jozsef Kadlecsik.

* Removal of redundant include in xt_CT from Eldad Zack.

* Fix for wrong usage of MODULE_ALIAS_NFCT_HELPER in nf_ct_h323
  helper from myself.

You can pull these changes from:

git://1984.lsi.us.es/net master

Thanks!

Eldad Zack (1):
  netfilter: xt_CT: remove redundant header include

Jozsef Kadlecsik (2):
  netfilter: ipset: fix timeout value overflow bug
  netfilter: ipset: fix hash size checking in kernel

Pablo Neira Ayuso (1):
  netfilter: nf_ct_h323: fix usage of MODULE_ALIAS_NFCT_HELPER

 include/linux/netfilter/ipset/ip_set_ahash.h   |   16 ++++++++++++++++
 include/linux/netfilter/ipset/ip_set_timeout.h |    4 ++++
 net/netfilter/ipset/ip_set_hash_ip.c           |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_ipport.c       |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_net.c          |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_netiface.c     |   10 +++++++---
 net/netfilter/ipset/ip_set_hash_netport.c      |   10 +++++++---
 net/netfilter/nf_conntrack_h323_main.c         |    4 +++-
 net/netfilter/xt_CT.c                          |    1 -
 net/netfilter/xt_set.c                         |   15 +++++++++++++--
 12 files changed, 85 insertions(+), 25 deletions(-)

-- 
1.7.10

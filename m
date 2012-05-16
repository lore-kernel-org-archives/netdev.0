From: pablo@netfilter.org
Subject: [PATCH 0/7] netfilter updates for net-next (batch 3)
Date: Thu, 17 May 2012 01:06:37 +0200
Message-ID: <1337209604-3412-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39184 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760763Ab2EPXH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2012 19:07:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains small updates for net-next, more relevantly:

* One fix for potential NULL dereference in xt_HMARK by Dan Carpenter.

* Conversion to use _ALL macro in xt_hashlimit as you suggested by
  Florian Westphal.

* One fix for timeout overflow from Jozsef Kadlecsik.

* Replace usage of modulus for hash calculation in xt_HMARK as you suggested
  from myself.

You can pull these changes from:

git://1984.lsi.us.es/net-next master

Thanks!

Dan Carpenter (1):
  netfilter: xt_HMARK: potential NULL dereference in get_inner_hdr()

Eldad Zack (1):
  netfilter: xt_CT: remove redundant header include

Florian Westphal (1):
  netfilter: xt_hashlimit: use _ALL macro to reject unknown flag bits

Jozsef Kadlecsik (1):
  netfilter: ipset: fix timeout value overflow bug

Pablo Neira Ayuso (3):
  netfilter: xt_HMARK: modulus is expensive for hash calculation
  netfilter: nf_ct_tcp: extend log message for invalid ignored packets
  netfilter: nf_ct_h323: fix usage of MODULE_ALIAS_NFCT_HELPER

 include/linux/netfilter/ipset/ip_set_timeout.h |    4 ++++
 include/linux/netfilter/xt_hashlimit.h         |    6 ++++--
 net/netfilter/nf_conntrack_h323_main.c         |    4 +++-
 net/netfilter/nf_conntrack_proto_tcp.c         |    3 ++-
 net/netfilter/xt_CT.c                          |    1 -
 net/netfilter/xt_HMARK.c                       |    4 ++--
 net/netfilter/xt_hashlimit.c                   |    2 +-
 net/netfilter/xt_set.c                         |   15 +++++++++++++--
 8 files changed, 29 insertions(+), 10 deletions(-)

-- 
1.7.10

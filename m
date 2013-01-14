From: pablo@netfilter.org
Subject: [PATCH 0/3] netfilter fixes for 3.8-rc3
Date: Tue, 15 Jan 2013 00:24:02 +0100
Message-ID: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38546 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757927Ab3ANXYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 18:24:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following patchset contains netfilter fixes for 3.8-rc3,
they are:

* fix possible BUG_ON if several netns are in use and the nf_conntrack
  module is removed, initial patch from Gao feng, final patch from myself.

* fix unset return value if conntrack zone are disabled at
  compile-time, reported by Borislav Petkov, fix from myself.

* fix display error message via dmesg for arp_tables, from Jan Engelhardt.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Jan Engelhardt (1):
  netfilter: x_tables: print correct hook names for ARP

Pablo Neira Ayuso (2):
  netfilter: xt_CT: fix unset return value if conntrack zone are disabled
  netfilter: nf_conntrack: fix BUG_ON while removing nf_conntrack with netns

 include/net/netfilter/nf_conntrack_core.h |    2 ++
 net/netfilter/nf_conntrack_core.c         |    9 +++++----
 net/netfilter/nf_conntrack_standalone.c   |    1 +
 net/netfilter/x_tables.c                  |   28 ++++++++++++++++++++--------
 net/netfilter/xt_CT.c                     |    4 ++--
 5 files changed, 30 insertions(+), 14 deletions(-)

-- 
1.7.10.4

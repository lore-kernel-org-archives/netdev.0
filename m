From: pablo@netfilter.org
Subject: [PATCH 0/3] Netfilter fixes for 3.8-rc2
Date: Mon,  7 Jan 2013 21:04:04 +0100
Message-ID: <1357589047-3373-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57374 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753569Ab3AGUES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 15:04:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Hi David,

The following batch contains Netfilter fixes for 3.8-rc2, they are:

* Fix IPv6 stateless network/port translation (NPT) checksum
  calculation, from Ulrich Weber.

* Fix for xt_recent to avoid memory allocation failures if large
  hashtables are used, from Eric Dumazet.

* Fix missing dependencies in Kconfig for the deprecated NOTRACK,
  from myself.

You can pull these changes from:

git://1984.lsi.us.es/nf master

Thanks!

Eric Dumazet (1):
  netfilter: xt_recent: avoid high order page allocations

Pablo Neira Ayuso (1):
  netfilter: fix missing dependencies for the NOTRACK target

Ulrich Weber (1):
  netfilter: ip6t_NPT: fix IPv6 NTP checksum calculation

 net/ipv6/netfilter/ip6t_NPT.c |   33 +++++++--------------------------
 net/netfilter/Kconfig         |    3 +++
 net/netfilter/xt_recent.c     |   23 ++++++++++++++++++-----
 3 files changed, 28 insertions(+), 31 deletions(-)

-- 
1.7.10.4

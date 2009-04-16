From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/03: netfilter fixes
Date: Thu, 16 Apr 2009 19:16:22 +0200 (MEST)
Message-ID: <20090416171621.11406.78609.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61767 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755463AbZDPRQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 13:16:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following three patches fix two netfilter bugs introduced during the merge
window and re-add support for a feature that accidentally got dropped with the
SAME target removal:

- a missing list initialization of the nf_log logger lists

- a missing conversion to use the hlist_nulls list function in connection tracking
  helper unregistration

- support for persistent multi-range NAT mappings

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Thanks!


 include/net/netfilter/nf_nat.h      |    1 +
 net/ipv4/netfilter/nf_nat_core.c    |    3 ++-
 net/netfilter/nf_conntrack_helper.c |    2 +-
 net/netfilter/nf_log.c              |    4 ++++
 4 files changed, 8 insertions(+), 2 deletions(-)

Eric Dumazet (1):
      netfilter: nf_log regression fix

Patrick McHardy (2):
      netfilter: nf_conntrack: fix crash when unloading helpers
      netfilter: nf_nat: add support for persistent mappings

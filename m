From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/03: netfilter update
Date: Fri, 26 Feb 2010 18:15:21 +0100 (MET)
Message-ID: <20100226171521.30040.76590.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59973 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965152Ab0BZRPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 12:15:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are a few more late patches for netfilter, containing:

- Simon's list_head conversion in ip_vs_lblcr

- a patch to restore indentation in xtables from Jan

- a nfnetlink_log reference count fix from Alexey

I'll send all relevant fixes from this and the last nf-next updates
to -stable once they appear in mainline.

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 net/ipv4/netfilter/arp_tables.c  |   23 ++++++++++++-------
 net/ipv4/netfilter/ip_tables.c   |   25 +++++++++++++--------
 net/ipv6/netfilter/ip6_tables.c  |   25 +++++++++++++--------
 net/netfilter/ipvs/ip_vs_lblcr.c |   44 ++++++++++++++++++-------------------
 net/netfilter/nfnetlink_log.c    |    2 +-
 5 files changed, 66 insertions(+), 53 deletions(-)

Alexey Dobriyan (1):
      netfilter: nfnetlink_log: fix silly refcount leak

Jan Engelhardt (1):
      netfilter: xtables: restore indentation

Simon Horman (1):
      IPVS: ip_vs_lblcr: use list headA

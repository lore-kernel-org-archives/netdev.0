From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter fixes for net
Date: Thu, 14 Apr 2016 00:54:51 +0200
Message-ID: <1460588094-3933-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40580 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753987AbcDMWzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 18:55:08 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 9D58D73EF
	for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 00:55:06 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 90773A737
	for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 00:55:06 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 5211BA79D
	for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 00:55:04 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for your net tree. More
specifically, they are:

1) Fix missing filter table per-netns registration in arptables, from
   Florian Westphal.

2) Resolve out of bound access when parsing TCP options in
   nf_conntrack_tcp, patch from Jozsef Kadlecsik.

3) Prefer NFPROTO_BRIDGE extensions over NFPROTO_UNSPEC in ebtables,
   this resolves conflict between xt_limit and ebt_limit, from Phil Sutter.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 0a1a37b6d62e6864a77a82e925217c720f91f963:

  net: add the AF_KCM entries to family name tables (2016-04-06 16:59:01 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to bcf4934288402be3464110109a4dae3bd6fb3e93:

  netfilter: ebtables: Fix extension lookup with identical name (2016-04-13 01:16:57 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: arp_tables: register table in initns

Jozsef Kadlecsik (1):
      netfilter: nf_conntrack_tcp: Fix stack out of bounds when parsing TCP options

Phil Sutter (1):
      netfilter: ebtables: Fix extension lookup with identical name

 net/bridge/netfilter/ebtables.c        | 6 +++++-
 net/ipv4/netfilter/arptable_filter.c   | 6 ++++++
 net/netfilter/nf_conntrack_proto_tcp.c | 4 ++++
 3 files changed, 15 insertions(+), 1 deletion(-)

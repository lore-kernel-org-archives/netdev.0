From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 0/6] ipv6: netfilter - coding style improvements
Date: Sat, 25 Apr 2015 10:26:54 +0100
Message-ID: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36719 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758803AbbDYJ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 05:27:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches removes some style issues in the ipv6 netfilter
code detected by checkpatch. There is no change to functionality and
no changes to the resultant object determined by objdiff.


Ian Morris (6):
  ipv6: netfilter: Tidy up indenting
  ipv6: netfilter: whitespace in line layouts
  ipv6: netfilter: remove unnecessary braces
  ipv6: netfilter: comparison for equality with NULL
  ipv6: netfilter: comparison for inequality with NULL
  ipv6: netfilter: simply if-else statements

 net/ipv6/netfilter/ip6_tables.c                |  40 ++++-----
 net/ipv6/netfilter/ip6t_REJECT.c               |   2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  18 ++--
 net/ipv6/netfilter/ip6t_ah.c                   |  18 ++--
 net/ipv6/netfilter/ip6t_frag.c                 |  26 +++---
 net/ipv6/netfilter/ip6t_hbh.c                  | 114 ++++++++++++-------------
 net/ipv6/netfilter/ip6t_ipv6header.c           |   2 +-
 net/ipv6/netfilter/ip6t_mh.c                   |   2 +-
 net/ipv6/netfilter/ip6t_rpfilter.c             |   2 +-
 net/ipv6/netfilter/ip6t_rt.c                   | 102 +++++++++++-----------
 net/ipv6/netfilter/ip6table_filter.c           |   2 +-
 net/ipv6/netfilter/ip6table_mangle.c           |   2 +-
 net/ipv6/netfilter/ip6table_nat.c              |   2 +-
 net/ipv6/netfilter/ip6table_raw.c              |   2 +-
 net/ipv6/netfilter/ip6table_security.c         |   2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  15 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        |  26 +++---
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |   2 +-
 net/ipv6/netfilter/nf_log_ipv6.c               |  16 ++--
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |   2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c            |  10 +--
 net/ipv6/netfilter/nf_tables_ipv6.c            |   2 +-
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |   6 +-
 net/ipv6/netfilter/nft_reject_ipv6.c           |   2 +-
 25 files changed, 205 insertions(+), 214 deletions(-)

-- 
1.9.1

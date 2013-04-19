From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/5] Netfilter updates for net-next
Date: Fri, 19 Apr 2013 03:23:52 +0200
Message-ID: <1366334638-5113-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57200 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967524Ab3DSBYJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 21:24:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains a small batch of Netfilter
updates for your net-next tree, they are:

* Three patches that provide more accurate error reporting to
  user-space, instead of -EPERM, in IPv4/IPv6 netfilter re-routing
  code and NAT, from Patrick McHardy.

* Update copyright statements in Netfilter filters of
  Patrick McHardy, from himself.

* Add Kconfig dependency on the raw/mangle tables to the
  rpfilter, from Florian Westphal.

The following changes since commit 6b0ee8c036ecb3ac92e18e6ca0dca7bff88beaf0:

  scm: Stop passing struct cred (2013-04-07 18:58:55 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to d37d696804a83479f240b397670a07ccb53a7417:

  netfilter: xt_rpfilter: depend on raw or mangle table (2013-04-19 00:22:55 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      netfilter: xt_rpfilter: depend on raw or mangle table

Patrick McHardy (4):
      netfilter: ipv4: propagate routing errors from ip_route_me_harder()
      netfilter: ipv6: propagate routing errors from ip6_route_me_harder()
      netfilter: nat: propagate errors from xfrm_me_harder()
      netfilter: add my copyright statements

 net/ipv4/netfilter.c                               |   15 ++++++++-----
 net/ipv4/netfilter/Kconfig                         |    2 +-
 net/ipv4/netfilter/arp_tables.c                    |    1 +
 net/ipv4/netfilter/ip_tables.c                     |    1 +
 net/ipv4/netfilter/ipt_ULOG.c                      |    1 +
 net/ipv4/netfilter/iptable_mangle.c                |    9 +++++---
 net/ipv4/netfilter/iptable_nat.c                   |   23 +++++++++++++-------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    1 +
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    1 +
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c       |    1 +
 net/ipv4/netfilter/nf_nat_h323.c                   |    1 +
 net/ipv4/netfilter/nf_nat_pptp.c                   |    2 ++
 net/ipv4/netfilter/nf_nat_proto_gre.c              |    2 ++
 net/ipv4/netfilter/nf_nat_snmp_basic.c             |    2 ++
 net/ipv6/netfilter.c                               |   12 +++++++---
 net/ipv6/netfilter/Kconfig                         |    2 +-
 net/ipv6/netfilter/ip6_tables.c                    |    1 +
 net/ipv6/netfilter/ip6t_REJECT.c                   |    2 ++
 net/ipv6/netfilter/ip6table_mangle.c               |    9 +++++---
 net/ipv6/netfilter/ip6table_nat.c                  |   23 +++++++++++++-------
 net/netfilter/core.c                               |    1 +
 net/netfilter/nf_conntrack_amanda.c                |    1 +
 net/netfilter/nf_conntrack_core.c                  |    1 +
 net/netfilter/nf_conntrack_ecache.c                |    8 ++++---
 net/netfilter/nf_conntrack_expect.c                |    1 +
 net/netfilter/nf_conntrack_ftp.c                   |    1 +
 net/netfilter/nf_conntrack_h323_main.c             |    1 +
 net/netfilter/nf_conntrack_helper.c                |    1 +
 net/netfilter/nf_conntrack_irc.c                   |    1 +
 net/netfilter/nf_conntrack_pptp.c                  |    2 ++
 net/netfilter/nf_conntrack_proto.c                 |    1 +
 net/netfilter/nf_conntrack_proto_gre.c             |    1 +
 net/netfilter/nf_conntrack_proto_sctp.c            |    3 +++
 net/netfilter/nf_conntrack_proto_tcp.c             |    2 ++
 net/netfilter/nf_conntrack_proto_udp.c             |    1 +
 net/netfilter/nf_conntrack_standalone.c            |    1 +
 net/netfilter/nf_conntrack_tftp.c                  |    2 +-
 net/netfilter/nf_nat_amanda.c                      |    1 +
 net/netfilter/nf_nat_core.c                        |    9 ++++----
 net/netfilter/nf_nat_helper.c                      |    1 +
 net/netfilter/nf_queue.c                           |    5 +++++
 net/netfilter/nfnetlink_log.c                      |    1 +
 net/netfilter/x_tables.c                           |    1 +
 net/netfilter/xt_TCPMSS.c                          |    1 +
 net/netfilter/xt_conntrack.c                       |    1 +
 net/netfilter/xt_hashlimit.c                       |    1 +
 net/netfilter/xt_limit.c                           |    1 +
 47 files changed, 122 insertions(+), 40 deletions(-)

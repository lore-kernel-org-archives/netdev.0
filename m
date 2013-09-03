From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] net_random_N, reciprocal_divide helper updates
Date: Tue,  3 Sep 2013 12:26:48 +0200
Message-ID: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759834Ab3ICK0w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 06:26:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a net_random_N() helper instead of reimplementing it over and
over, plus use reciprocal_divide() helper instead of reimplementing it
as well.

Daniel Borkmann (2):
  net: introduce generic net_random_N helper
  net: use reciprocal_divide instead of reimplementing it

 drivers/net/team/team_mode_random.c | 7 +------
 include/linux/net.h                 | 7 +++++++
 include/net/red.h                   | 2 +-
 net/802/garp.c                      | 2 +-
 net/802/mrp.c                       | 2 +-
 net/core/dev.c                      | 2 +-
 net/core/flow_dissector.c           | 5 ++---
 net/ipv4/inet_hashtables.c          | 2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c  | 2 +-
 net/ipv4/udp.c                      | 6 +++---
 net/ipv6/inet6_hashtables.c         | 2 +-
 net/ipv6/udp.c                      | 4 ++--
 net/netfilter/nf_conntrack_core.c   | 2 +-
 net/netfilter/nf_conntrack_expect.c | 2 +-
 net/netfilter/nf_nat_core.c         | 4 ++--
 net/netfilter/xt_HMARK.c            | 2 +-
 net/netfilter/xt_NFQUEUE.c          | 4 ++--
 net/netfilter/xt_cluster.c          | 2 +-
 net/netfilter/xt_hashlimit.c        | 2 +-
 net/packet/af_packet.c              | 2 +-
 net/sched/sch_choke.c               | 8 +-------
 net/sched/sch_fq_codel.c            | 2 +-
 22 files changed, 34 insertions(+), 39 deletions(-)

-- 
1.7.11.7

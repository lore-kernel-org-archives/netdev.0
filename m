From: Patrick McHardy <kaber@trash.net>
Subject: [NET 00/02]: Remove NET_ACT_NAT dependency on NETFILTER
Date: Thu, 29 Nov 2007 10:57:34 +0100 (MET)
Message-ID: <20071129095733.11756.86966.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches remove the dependency of NET_ACT_NAT on NETFILTER
by moving the netfilter checksum helpers to include/net/checksum
and net/core/utils.c. I didn't find more appropriate locations,
but I'd happily change it if someone suggests something better.


 include/linux/netfilter.h              |   22 ----------------------
 include/net/checksum.h                 |   25 +++++++++++++++++++++++++
 net/core/utils.c                       |   16 ++++++++++++++++
 net/ipv4/netfilter/ipt_ECN.c           |    6 +++---
 net/ipv4/netfilter/ipt_TOS.c           |    2 +-
 net/ipv4/netfilter/ipt_TTL.c           |    4 ++--
 net/ipv4/netfilter/nf_nat_core.c       |    4 ++--
 net/ipv4/netfilter/nf_nat_helper.c     |   20 ++++++++++----------
 net/ipv4/netfilter/nf_nat_proto_icmp.c |    4 ++--
 net/ipv4/netfilter/nf_nat_proto_tcp.c  |    4 ++--
 net/ipv4/netfilter/nf_nat_proto_udp.c  |    6 +++---
 net/netfilter/core.c                   |   16 ----------------
 net/netfilter/xt_TCPMSS.c              |   17 +++++++++--------
 net/sched/Kconfig                      |    1 -
 net/sched/act_nat.c                    |   12 ++++++------
 15 files changed, 81 insertions(+), 78 deletions(-)

Patrick McHardy (2):
      [NET]: Move netfilter checksum helpers to net/core/utils.c
      [NETFILTER]: Convert old checksum helper names

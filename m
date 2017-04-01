From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 0/2] Simplify NULL comparisons
Date: Sat,  1 Apr 2017 21:43:18 +0530
Message-ID: <20170401161320.8247-1-arushisinghal19971997@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify NULL comparisons to follow kernel coding style.

Arushi Singhal (2):
  ipv4: netfilter: Simplify NULL comparisons
  ipv6: netfilter: Simplify NULL comparisons

 net/ipv4/netfilter/arp_tables.c                |  3 +--
 net/ipv4/netfilter/arptable_filter.c           |  2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              | 16 ++++++++--------
 net/ipv4/netfilter/iptable_filter.c            |  2 +-
 net/ipv4/netfilter/iptable_mangle.c            |  2 +-
 net/ipv4/netfilter/iptable_nat.c               |  2 +-
 net/ipv4/netfilter/iptable_raw.c               |  2 +-
 net/ipv4/netfilter/iptable_security.c          |  2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  4 ++--
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |  4 ++--
 net/ipv4/netfilter/nf_dup_ipv4.c               |  2 +-
 net/ipv4/netfilter/nf_log_arp.c                |  4 ++--
 net/ipv4/netfilter/nf_log_ipv4.c               | 10 +++++-----
 net/ipv4/netfilter/nf_nat_snmp_basic.c         | 22 +++++++++++-----------
 net/ipv4/netfilter/nf_reject_ipv4.c            |  2 +-
 net/ipv4/netfilter/nf_socket_ipv4.c            |  8 ++++----
 net/ipv4/netfilter/nf_tables_arp.c             |  2 +-
 net/ipv4/netfilter/nf_tables_ipv4.c            |  2 +-
 net/ipv4/netfilter/nft_dup_ipv4.c              |  2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             | 16 ++++++++--------
 net/ipv6/netfilter/ip6t_ipv6header.c           |  2 +-
 net/ipv6/netfilter/ip6table_filter.c           |  2 +-
 net/ipv6/netfilter/ip6table_mangle.c           |  2 +-
 net/ipv6/netfilter/ip6table_nat.c              |  2 +-
 net/ipv6/netfilter/ip6table_raw.c              |  2 +-
 net/ipv6/netfilter/ip6table_security.c         |  2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |  4 ++--
 net/ipv6/netfilter/nf_conntrack_reasm.c        | 12 ++++++------
 net/ipv6/netfilter/nf_dup_ipv6.c               |  2 +-
 net/ipv6/netfilter/nf_log_ipv6.c               | 12 ++++++------
 net/ipv6/netfilter/nf_reject_ipv6.c            |  4 ++--
 net/ipv6/netfilter/nf_socket_ipv6.c            |  8 ++++----
 net/ipv6/netfilter/nf_tables_ipv6.c            |  2 +-
 net/ipv6/netfilter/nft_dup_ipv6.c              |  2 +-
 36 files changed, 85 insertions(+), 86 deletions(-)

-- 
2.11.0

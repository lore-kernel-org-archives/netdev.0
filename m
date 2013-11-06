From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] netfilter: push reasm skb through instead of original frag skbs
Date: Wed,  6 Nov 2013 17:52:18 +0100
Message-ID: <1383756740-7392-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Pirko (2):
  ip6_output: fragment outgoing reassembled skb properly
  netfilter: push reasm skb through instead of original frag skbs

 include/linux/skbuff.h                         | 32 ---------------
 include/net/ip_vs.h                            | 32 +--------------
 include/net/netfilter/ipv6/nf_defrag_ipv6.h    |  4 +-
 net/core/skbuff.c                              |  3 --
 net/ipv6/ip6_output.c                          |  3 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 56 +-------------------------
 net/ipv6/netfilter/nf_conntrack_reasm.c        | 19 +--------
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  7 +++-
 net/netfilter/ipvs/ip_vs_core.c                | 55 +------------------------
 net/netfilter/ipvs/ip_vs_pe_sip.c              |  8 +---
 10 files changed, 15 insertions(+), 204 deletions(-)

-- 
1.8.3.1


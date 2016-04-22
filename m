From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/9] netlink: align attributes when needed (patchset #1)
Date: Fri, 22 Apr 2016 17:31:15 +0200
Message-ID: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, aar@pengutronix.de,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53513 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488AbcDVPcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 11:32:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the continuation of the work done to align netlink attributes
when these attributes contain some 64-bit fields.

David, if the third patch is too big (or maybe the series), I can split it.
Just tell me what you prefer.

 include/linux/netfilter/ipset/ip_set.h             |  9 ++--
 include/net/netlink.h                              | 60 ++++++++++++++++------
 include/net/nl802154.h                             |  6 +++
 include/uapi/linux/fib_rules.h                     |  1 +
 include/uapi/linux/l2tp.h                          |  1 +
 include/uapi/linux/lwtunnel.h                      |  2 +
 include/uapi/linux/neighbour.h                     |  2 +
 include/uapi/linux/netfilter/ipset/ip_set.h        |  1 +
 include/uapi/linux/netfilter/nf_tables.h           |  8 +++
 include/uapi/linux/netfilter/nfnetlink_acct.h      |  1 +
 include/uapi/linux/netfilter/nfnetlink_conntrack.h |  3 ++
 include/uapi/linux/openvswitch.h                   |  1 +
 include/uapi/linux/tcp_metrics.h                   |  1 +
 include/uapi/linux/xfrm.h                          |  1 +
 kernel/taskstats.c                                 | 37 ++-----------
 lib/nlattr.c                                       |  8 ++-
 net/core/fib_rules.c                               |  4 +-
 net/core/neighbour.c                               | 19 +++----
 net/ieee802154/nl802154.c                          | 13 +++--
 net/ipv4/ip_tunnel_core.c                          | 10 ++--
 net/ipv4/tcp_metrics.c                             |  6 ++-
 net/l2tp/l2tp_netlink.c                            |  3 +-
 net/netfilter/nf_conntrack_netlink.c               | 18 ++++---
 net/netfilter/nf_conntrack_proto_dccp.c            |  4 +-
 net/netfilter/nf_tables_api.c                      | 24 ++++++---
 net/netfilter/nf_tables_trace.c                    |  5 +-
 net/netfilter/nfnetlink_acct.c                     |  9 ++--
 net/netfilter/nft_counter.c                        |  6 ++-
 net/netfilter/nft_dynset.c                         |  3 +-
 net/netfilter/nft_limit.c                          |  6 ++-
 net/openvswitch/flow_netlink.c                     |  5 +-
 net/xfrm/xfrm_user.c                               | 10 ++--
 32 files changed, 178 insertions(+), 109 deletions(-)

Comments are welcomed,
Regards,
Nicolas

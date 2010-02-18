From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/09: netfilter update part II
Date: Thu, 18 Feb 2010 19:21:03 +0100 (MET)
Message-ID: <20100218182103.21826.17908.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38159 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab0BRSVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 13:21:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

following are a few more netfilter patches for 2.6.34, containing:

- bridge netfilter compat support from Florian Westphal

- IPVS SCTP load-balancing support from Venkata Mohan Reddy

- a build fix for nf_defrag_ipv4 from myself

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 include/net/ip_vs.h                        |   22 +-
 include/net/netfilter/nf_conntrack_zones.h |    6 +-
 net/bridge/netfilter/ebt_limit.c           |   16 +
 net/bridge/netfilter/ebt_mark.c            |   31 +
 net/bridge/netfilter/ebt_mark_m.c          |   37 +
 net/bridge/netfilter/ebtables.c            | 1159 ++++++++++++++++++++++++---
 net/ipv4/netfilter/nf_defrag_ipv4.c        |    6 +-
 net/netfilter/ipvs/Kconfig                 |    7 +
 net/netfilter/ipvs/Makefile                |    1 +
 net/netfilter/ipvs/ip_vs_core.c            |   62 ++-
 net/netfilter/ipvs/ip_vs_ctl.c             |    5 +-
 net/netfilter/ipvs/ip_vs_proto.c           |    3 +
 net/netfilter/ipvs/ip_vs_proto_sctp.c      | 1183 ++++++++++++++++++++++++++++
 net/netfilter/ipvs/ip_vs_sync.c            |   14 +
 14 files changed, 2418 insertions(+), 134 deletions(-)
 create mode 100644 net/netfilter/ipvs/ip_vs_proto_sctp.c

Florian Westphal (7):
      netfilter: ebtables: split do_replace into two functions
      netfilter: ebtables: split copy_everything_to_user into two functions
      netfilter: ebtables: split update_counters into two functions
      netfilter: ebtables: add CONFIG_COMPAT support
      netfilter: ebtables: try native set/getsockopt handlers, too
      netfilter: ebt_limit: add CONFIG_COMPAT support
      netfilter: ebtables: mark: add CONFIG_COMPAT support

Patrick McHardy (2):
      Merge branch 'ebt_config_compat_v4' of git://git.breakpoint.cc/fw/nf-next-2.6
      netfilter: nf_defrag_ipv4: fix compilation error with NF_CONNTRACK=n

Venkata Mohan Reddy (1):
      ipvs: SCTP Trasport Loadbalancing Support

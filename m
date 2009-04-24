From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/05: netfilter fixes
Date: Fri, 24 Apr 2009 17:44:01 +0200 (MEST)
Message-ID: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47977 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbZDXPoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2009 11:44:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following patches fix a couple of netfilter bugs:

- fix for use of unintialized values in the recent match compat proc handling
  from Jan Engelhardt

- Removal of an incorrect TProxy dependency on conntrack from
  Laszlo Attila Toth

- Addition of missing netlink options for the DCCP conntrack protocol,
  from Pablo

- Fix for a conntrack protocol registration regression in 2.6.30-rc from myself

- A fix for bridge-netfilter re-fragmentation of VLAN packets defragmented
  by conntrack from Saikiran Madugula

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git

Thanks!


 include/linux/netfilter/nfnetlink_conntrack.h |    1 +
 net/bridge/br_netfilter.c                     |   10 +++++++++-
 net/netfilter/Kconfig                         |    4 ++--
 net/netfilter/nf_conntrack_proto_dccp.c       |   16 +++++++++++++++-
 net/netfilter/nf_conntrack_proto_udplite.c    |    1 +
 net/netfilter/xt_recent.c                     |    9 ++++-----
 6 files changed, 32 insertions(+), 9 deletions(-)

Jan Engelhardt (1):
      netfilter: xt_recent: fix stack overread in compat code

Laszlo Attila Toth (1):
      netfilter: Kconfig: TProxy doesn't depend on NF_CONNTRACK

Pablo Neira Ayuso (1):
      netfilter: nf_ct_dccp: add missing role attributes for DCCP

Patrick McHardy (1):
      netfilter: nf_ct_dccp/udplite: fix protocol registration error

hummerbliss@gmail.com (1):
      netfilter: bridge: allow fragmentation of VLAN packets traversing a bridge

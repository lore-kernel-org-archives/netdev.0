From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 00/04]: Two fixes + cls_flow VLAN tag based classification
Date: Tue,  5 Feb 2008 15:29:39 +0100 (MET)
Message-ID: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59215 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751763AbYBEO3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 09:29:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix a compile warning in em_meta, an invalid check in
the flow classifier and add VLAN tag based classification to cls_flow.
Please apply, thanks.


 include/linux/if_vlan.h |    7 ++++---
 include/linux/pkt_cls.h |    1 +
 net/sched/cls_flow.c    |   17 +++++++++++++++--
 net/sched/em_meta.c     |    2 +-
 4 files changed, 21 insertions(+), 6 deletions(-)

Patrick McHardy (4):
      [NET_SCHED]: em_meta: fix compile warning
      [NET_SCHED]: cls_flow: fix key mask validity check
      [VLAN]: Constify skb argument to vlan_get_tag()
      [NET_SCHED]: cls_flow: support classification based on VLAN tag

From: kaber@trash.net
Subject: [PATCH 00/28] netfilter: netfilter update
Date: Mon,  2 Aug 2010 21:57:17 +0200
Message-ID: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35359 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754710Ab0HBT55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:57:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

following is a final netfilter update for net-next, containing:

- fast path reassembly optimization for in-order fragments, from Changli Gao

- ipt_REJECT checksum offloading, from Changli Gao

- use of skb_dst_set_noref in ipt_REJECT, from Eric

- IPVS protocol handler invocation fixes, from Xiaoyu Du

- TCP connection tracking improvements for state synchronization, from Pablo

- a new 'CHECKSUM' target for working around broken virtualized applications,
  from Michael S. Tsirkin

- patches to make IPVS work with netfilter SNAT, from Hannes Eder

- a new 'cpu' match for distributing connections in a cache friendly manner,
  from Eric

- a fix for the quota match to dump the initial quota instead of the remaining
  one to userspace, from Changli Gao

- patches to use skb->len for accounting instead of the values contained in
  the header in order to fix jumbo frame handling, from Changli Gao

- reduction of the time *tables runs with BHs disabled when summing up the
  counters, from Eric

- IPVS code consolidation, from Simon

Please pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


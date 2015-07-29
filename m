From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 0/3] Backwards-compatible noqueue in virtual interfaces
Date: Wed, 29 Jul 2015 22:51:40 +0200
Message-ID: <1438203103-27013-1-git-send-email-phil@nwl.cc>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:57511 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbbG2Uvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 16:51:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series is inspired by a patch sent[1] in from Jesper Brouer and the
discussion it started. Basically it tries to provide a solution which is
backwards compatible while still enabling the veth performance
improvement by default.

[1]: http://www.spinics.net/lists/netdev/msg299407.html

Jesper Dangaard Brouer (1):
  veth: don't assign a qdisc to veth

Phil Sutter (2):
  net: make default tx_queue_len configurable
  net: sched: set tx_queue_len to default when changing noqueue device's
    qdisc

 drivers/net/veth.c  |  1 +
 net/Kconfig         | 12 ++++++++++++
 net/ethernet/eth.c  |  2 +-
 net/sched/sch_api.c |  4 ++++
 4 files changed, 18 insertions(+), 1 deletion(-)

-- 
2.1.2

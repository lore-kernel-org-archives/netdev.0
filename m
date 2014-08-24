From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 0/3] Some deferred TX queue follow-ups
Date: Sun, 24 Aug 2014 15:42:15 +0200
Message-ID: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11487 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752573AbaHXNmV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Aug 2014 09:42:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On top of Dave's `[PATCH 0/3] Basic deferred TX queue flushing infrastructure`.
It adds an implementation for ixgbe and a use-case for AF_PACKET's QDISC_BYPASS.

Daniel Borkmann (3):
  ixgbe: support netdev_ops->ndo_xmit_flush()
  net: add __netdev_xmit_{only,flush} helpers
  packet: make use of deferred TX queue flushing

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 28 ++++++++++++---
 include/linux/netdevice.h                     | 15 ++++++++
 net/packet/af_packet.c                        | 49 ++++++++++++++++++++-------
 3 files changed, 76 insertions(+), 16 deletions(-)

-- 
1.7.11.7

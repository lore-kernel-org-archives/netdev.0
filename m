From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] Towards accurate incoming interface information
Date: Mon, 26 Jun 2006 16:54:46 +0200
Message-ID: <20060626145446.948105000@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:21930 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932318AbWFZO6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 10:58:31 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset transforms skb->input_dev based on a device
reference to skb->iif based on an interface index moving
towards accurate iif information for routing and classification
through the following changesets:
                                 
        [NET]: Use interface index to keep input device information
        [VLAN]: Update iif when receiving via VLAN devic
        [PKT_SCHED]: Add iif meta match

 include/linux/skbuff.h               |    4 ++--
 include/linux/tc_ematch/tc_em_meta.h |    1 +
 include/net/pkt_cls.h                |   13 +++++++++----
 net/8021q/vlan_dev.c                 |    2 ++
 net/core/dev.c                       |    8 ++++----
 net/core/skbuff.c                    |    2 +-
 net/sched/act_api.c                  |    5 ++---
 net/sched/act_mirred.c               |    2 +-
 net/sched/em_meta.c                  |    6 ++++++
 9 files changed, 28 insertions(+), 15 deletions(-)


From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 0/2] Open vSwitch zerocopy upcall
Date: Fri, 24 May 2013 16:52:21 +0200
Message-ID: <cover.1369406826.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, eric.dumazet@gmail.com
To: netdev@vger.kernel.org, jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:35557 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657Ab3EXOwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 10:52:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Posting this to netdev due to dependency on first patch.

Thomas Graf (2):
  net: Export skb_zerocopy() to zerocopy from one skb to another
  openvswitch: Use zerocopy if applicable when performing the upcall

 include/linux/skbuff.h               |  2 ++
 net/core/skbuff.c                    | 46 +++++++++++++++++++++++++++++++++++
 net/netfilter/nfnetlink_queue_core.c | 47 +-----------------------------------
 net/openvswitch/datapath.c           | 38 ++++++++++++++++++++++++-----
 4 files changed, 81 insertions(+), 52 deletions(-)

-- 
1.7.11.7

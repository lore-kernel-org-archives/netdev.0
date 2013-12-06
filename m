From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] PF_PACKET updates
Date: Fri,  6 Dec 2013 11:36:14 +0100
Message-ID: <1386326177-4483-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754313Ab3LFKgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 05:36:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch descriptions in individual patches.

In order to avoid a possible merge conflict, we suggest to take
the first patch through net tree, merge net into net-next and
apply the remaining two patches on top of it. Dave, please let
us know if you like to handle this differently than suggested.

For patch 3 we'll send a man-page update as a follow-up.

Thanks !

Daniel Borkmann (3):
  packet: fix send path when running with proto == 0
  net: dev: move inline skb_needs_linearize helper to header
  packet: introduce PACKET_QDISC_BYPASS socket option

 Documentation/networking/packet_mmap.txt |  31 ++++++
 include/linux/skbuff.h                   |  18 ++++
 include/uapi/linux/if_packet.h           |   1 +
 net/core/dev.c                           |  15 ---
 net/packet/af_packet.c                   | 156 +++++++++++++++++++++++--------
 net/packet/internal.h                    |   1 +
 6 files changed, 170 insertions(+), 52 deletions(-)

-- 
1.8.3.1

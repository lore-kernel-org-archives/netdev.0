From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH 0/2] pf_packet fixes
Date: Wed,  2 Apr 2014 20:52:55 +0200
Message-ID: <1396464777-18375-1-git-send-email-dborkman@redhat.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52651 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932494AbaDBSxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2014 14:53:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applies to net-next tree. Thanks!

Daniel Borkmann (2):
  packet: report tx_dropped in packet_direct_xmit
  packet: fix packet_direct_xmit for BQL enabled drivers

 include/linux/netdevice.h | 24 +++++++++++++++++++-----
 net/packet/af_packet.c    |  3 ++-
 2 files changed, 21 insertions(+), 6 deletions(-)

-- 
1.7.11.7

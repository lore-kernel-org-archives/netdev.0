From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] pf_packet updates
Date: Wed, 28 Aug 2013 22:13:08 +0200
Message-ID: <1377720791-15844-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753464Ab3H1UNO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 16:13:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (3):
  net: packet: add random fanout scheduler
  net: packet: use reciprocal_divide in fanout_demux_hash
  net: packet: document available fanout policies

 Documentation/networking/packet_mmap.txt |  8 ++++++++
 include/uapi/linux/if_packet.h           |  1 +
 net/packet/af_packet.c                   | 15 +++++++++++++--
 3 files changed, 22 insertions(+), 2 deletions(-)

-- 
1.7.11.7

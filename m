From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] pf_packet updates
Date: Sun, 12 Jan 2014 17:22:45 +0100
Message-ID: <1389543768-20234-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbaALQWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 11:22:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (3):
  packet: improve socket create/bind latency in some cases
  packet: don't unconditionally schedule() in case of MSG_DONTWAIT
  packet: use percpu mmap tx frame pending refcount

 net/packet/af_packet.c | 105 +++++++++++++++++++++++++++++++++++++++----------
 net/packet/diag.c      |   1 +
 net/packet/internal.h  |   2 +-
 3 files changed, 86 insertions(+), 22 deletions(-)

-- 
1.7.11.7

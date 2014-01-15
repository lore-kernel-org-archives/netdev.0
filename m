From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 0/3] pf_packet updates
Date: Wed, 15 Jan 2014 16:25:33 +0100
Message-ID: <1389799536-23750-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037AbaAOPZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 10:25:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changelog:

v1->v2:
 - put assignments under bind lock in patch 1
 - added 2 more relevant patches

v2->v3:
 - made refcnt unsigned in patch 3
 - rest unchanged

Thanks !

Daniel Borkmann (3):
  packet: improve socket create/bind latency in some cases
  packet: don't unconditionally schedule() in case of MSG_DONTWAIT
  packet: use percpu mmap tx frame pending refcount

 net/packet/af_packet.c | 106 +++++++++++++++++++++++++++++++++++++++----------
 net/packet/diag.c      |   1 +
 net/packet/internal.h  |   2 +-
 3 files changed, 87 insertions(+), 22 deletions(-)

-- 
1.7.11.7

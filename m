From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 0/3] SCTP fixes
Date: Thu,  9 Oct 2014 22:55:30 +0200
Message-ID: <1412888133-833-1-git-send-email-dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65051 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbaJIUzg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2014 16:55:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are some SCTP fixes.

[ Note, immediate workaround would be to disable ASCONF (it
  is sysctl disabled by default). It is actually only used
  together with chunk authentication. ]

Thanks!

Daniel Borkmann (3):
  net: sctp: fix skb_over_panic when receiving malformed ASCONF chunks
  net: sctp: fix panic on duplicate ASCONF chunks
  net: sctp: fix remote memory pressure from excessive queueing

 include/net/sctp/sctp.h  |  5 +++
 include/net/sctp/sm.h    |  6 +--
 net/sctp/associola.c     |  2 +
 net/sctp/inqueue.c       | 33 ++++------------
 net/sctp/sm_make_chunk.c | 99 +++++++++++++++++++++++++++---------------------
 net/sctp/sm_statefuns.c  | 21 +++-------
 6 files changed, 77 insertions(+), 89 deletions(-)

-- 
1.7.11.7

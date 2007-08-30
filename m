From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT PULL] SCTP updates
Date: Thu, 30 Aug 2007 17:26:30 -0400
Message-ID: <11885091901093-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:44511 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755369AbXH3V1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 17:27:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Please pull the  following changes since commit
b07d68b5ca4d55a16fab223d63d5fb36f89ff42f:
  Linus Torvalds (1):
        Linux 2.6.23-rc4

that are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git master

Vlad Yasevich (7):
      SCTP: properly clean up fragment and ordering queues during FWD-TSN.
      SCTP: Assign stream sequence numbers to the entire message
      SCTP: Pick the correct port when binding to 0.
      SCTP: Uncomfirmed transports can't become Inactive
      SCTP: Do not retransmit chunks that are newer then rtt.
      SCTP: Correctly disable listening when backlog is 0.
      SCTP: Abort on COOKIE-ECHO if backlog is exceeded.

Wei Yongjun (4):
      SCTP: Fix sctp_addto_chunk() to add pad with correct length
      SCTP: Fix to encode PROTOCOL VIOLATION error cause correctly
      SCTP: Use net_ratelimit to suppress error messages print too fast
      SCTP: Fix to handle invalid parameter length correctly

 include/net/sctp/sm.h       |    2 +-
 include/net/sctp/structs.h  |    1 +
 include/net/sctp/ulpqueue.h |    1 +
 net/sctp/associola.c        |    7 ++-
 net/sctp/outqueue.c         |    7 +++
 net/sctp/sm_make_chunk.c    |  112 +++++++++++++++++++++++++++++-------------
 net/sctp/sm_sideeffect.c    |    8 ++-
 net/sctp/sm_statefuns.c     |   51 ++++++++++----------
 net/sctp/socket.c           |    3 +
 net/sctp/ulpqueue.c         |   75 ++++++++++++++++++++++++-----
 10 files changed, 190 insertions(+), 77 deletions(-)

Thanks
-vlad

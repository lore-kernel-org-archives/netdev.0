From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT PATCHES 0/13] SCTP fixes
Date: Wed,  7 Nov 2007 12:46:18 -0500
Message-ID: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:33934 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079AbXKGR4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 12:56:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

The following are the accumulated SCTP patches.  You can also pull
from:
 master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git pending

Vlad Yasevich (11):
      SCTP: Fix difference cases of retransmit.
      SCTP: Update RCU handling during the ADD-IP case
      SCTP: Correctly disable ADD-IP when AUTH is not supported.
      SCTP: Allow ADD_IP to work with AUTH for backward compatibility.
      SCTP: Fix a potential race between timers and receive path.
      SCTP: Use hashed lookup when looking for an association.
      SCTP: Convert custom hash lists to use hlist.
      SCTP: Make sctp_verify_param return multiple indications.
      SCTP: Fix PR-SCTP to deliver all the accumulated ordered chunks
      SCTP: Clean-up some defines for regressions tests.
      SCTP: Always flush the queue when uncorking.

Wei Yongjun (2):
      SCTP : Fix bad formatted comment in outqueue.c
      SCTP : Fix to process bundled ASCONF chunk correctly

 include/net/sctp/command.h   |    1 +
 include/net/sctp/constants.h |    3 +
 include/net/sctp/sctp.h      |    5 +-
 include/net/sctp/structs.h   |   22 +++---
 net/sctp/associola.c         |   10 ++-
 net/sctp/bind_addr.c         |   13 +---
 net/sctp/endpointola.c       |   34 ++++++---
 net/sctp/input.c             |   43 +++--------
 net/sctp/inqueue.c           |    4 +
 net/sctp/outqueue.c          |   41 +++++-----
 net/sctp/proc.c              |    6 +-
 net/sctp/protocol.c          |    7 +-
 net/sctp/sm_make_chunk.c     |  170 ++++++++++++++++++++++-------------------
 net/sctp/sm_sideeffect.c     |   10 ++-
 net/sctp/sm_statefuns.c      |    2 +-
 net/sctp/socket.c            |   16 ++---
 net/sctp/sysctl.c            |    9 ++
 net/sctp/transport.c         |    5 +-
 net/sctp/ulpqueue.c          |    2 +-
 19 files changed, 214 insertions(+), 189 deletions(-)



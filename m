From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT-PULL Request]: SCTP fixes
Date: Fri,  8 Feb 2008 15:27:21 -0500
Message-ID: <1202502441-16789-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:43795 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760976AbYBHU1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 15:27:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

The following changes since commit 3113e88c3cb3c0a22920b621f8e4d1f2ccc07f1e:
  Stephen Hemminger (1):
        [PKT_SCHED]: vlan tag match

are available in the git repository at:

  vxy@master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git pending

Vlad Yasevich (6):
      [SCTP]: Stop claiming that this is a "reference implementation"
      [SCTP]: Do not increase rwnd when reading partial notification.
      [SCTP]: Kill silly inlines in ulpqueue.c
      [SCTP]: Correctly reap SSNs when processing FORWARD_TSN chunk
      [SCTP]: Set ports in every address returned by sctp_getladdrs()
      [SCTP]: Make sure the chunk is off the transmitted list prior to freeing.

Wei Yongjun (1):
      [SCTP]: Fix kernel panic while received ASCONF chunk with bad serial number

 include/linux/sctp.h         |    4 +-
 include/net/sctp/auth.h      |    8 +++---
 include/net/sctp/command.h   |    8 +++---
 include/net/sctp/constants.h |    8 +++---
 include/net/sctp/sctp.h      |    8 +++---
 include/net/sctp/sm.h        |    8 +++---
 include/net/sctp/structs.h   |    8 +++---
 include/net/sctp/tsnmap.h    |    8 +++---
 include/net/sctp/ulpevent.h  |    8 +++---
 include/net/sctp/ulpqueue.h  |    6 ++--
 include/net/sctp/user.h      |    8 +++---
 net/sctp/associola.c         |   14 ++++++------
 net/sctp/auth.c              |    8 +++---
 net/sctp/bind_addr.c         |    8 +++---
 net/sctp/chunk.c             |    8 +++---
 net/sctp/command.c           |    8 +++---
 net/sctp/debug.c             |   12 +++-------
 net/sctp/endpointola.c       |   12 +++-------
 net/sctp/input.c             |    8 +++---
 net/sctp/inqueue.c           |    8 +++---
 net/sctp/ipv6.c              |    8 +++---
 net/sctp/objcnt.c            |    8 +++---
 net/sctp/output.c            |    8 +++---
 net/sctp/outqueue.c          |   12 ++++++----
 net/sctp/primitive.c         |    8 +++---
 net/sctp/proc.c              |    8 +++---
 net/sctp/protocol.c          |    8 +++---
 net/sctp/sm_make_chunk.c     |    9 ++++---
 net/sctp/sm_sideeffect.c     |    8 +++---
 net/sctp/sm_statefuns.c      |   10 +++-----
 net/sctp/sm_statetable.c     |    8 +++---
 net/sctp/socket.c            |   17 +++++++++++----
 net/sctp/ssnmap.c            |    8 +++---
 net/sctp/sysctl.c            |    8 +++---
 net/sctp/transport.c         |    8 +++---
 net/sctp/tsnmap.c            |    8 +++---
 net/sctp/ulpevent.c          |    7 +++--
 net/sctp/ulpqueue.c          |   43 +++++++++++++++++++++++++++++------------
 38 files changed, 190 insertions(+), 172 deletions(-)

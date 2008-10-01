From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: pull request: net-next sctp updates
Date: Wed,  1 Oct 2008 14:14:52 -0400
Message-ID: <1222884892-22938-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:26283 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753204AbYJASOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 14:14:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Please consider the following sctp work for net-next.

The following changes since commit bcd41303f422015ab662c9276d108414aa75b796:
  KOVACS Krisztian (1):
        udp: Export UDP socket lookup function

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/vxy/lksctp-dev.git net-next

Neil Horman (1):
      sctp: reduce memory footprint of sctp_chunk structure

Vlad Yasevich (6):
      sctp: Only mark chunks as missing when there are gaps
      sctp: Optimize SFR-CACC transport list walking during SACK processing
      sctp: Retransmit list is ineligable for missing indications
      sctp: try harder to figure out address family when checking wildcards
      sctp: enable cookie-echo retransmission transport switch
      sctp: correctly save sctp_adaptation from parameter.

Wei Yongjun (2):
      sctp: Fix to start T5-shutdown-guard timer while enter SHUTDOWN-SENT state
      sctp: Fix the SNMP counter of SCTP_MIB_OUTOFBLUES

 include/net/sctp/structs.h |   33 ++++++++++--------
 net/sctp/bind_addr.c       |   16 +++++++--
 net/sctp/ipv6.c            |    5 ++-
 net/sctp/output.c          |    2 +-
 net/sctp/outqueue.c        |   65 +++++++++++++++++++-----------------
 net/sctp/sm_make_chunk.c   |    4 +-
 net/sctp/sm_sideeffect.c   |   78 +++++++++++++++++++++++++-------------------
 net/sctp/sm_statefuns.c    |   36 +++++++++-----------
 net/sctp/sm_statetable.c   |    2 +-
 net/sctp/socket.c          |   10 +++---
 10 files changed, 139 insertions(+), 112 deletions(-)

Thanks
-vlad

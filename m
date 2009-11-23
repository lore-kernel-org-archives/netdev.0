From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: pull request: SCTP updates for net-next
Date: Mon, 23 Nov 2009 16:06:50 -0500
Message-ID: <4B0AF96A.3050709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux SCTP Dev Mailing list <linux-sctp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:26871 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756094AbZKWVGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 16:06:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Here is a set of SCTP patches for net-next.  Please pull.

The following changes since commit dc63d3771cc6492220f53caf5fded6090d45d9ce:
  Alexander Duyck (1):
        ixgbe: Only set/clear VFE in ixgbe_set_rx_mode

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/vxy/lksctp-dev.git net-next

Amerigo Wang (1):
      sctp: remove deprecated SCTP_GET_*_OLD stuffs

Andrei Pelinescu-Onciul (3):
      sctp: allow setting path_maxrxt independent of SPP_PMTUD_ENABLE
      sctp: limit maximum autoclose setsockopt value
      sctp: fix integer overflow when setting the autoclose timer

Neil Horman (1):
      sctp: Fix mis-ordering of user space data when multihoming in use

Vlad Yasevich (7):
      sctp: Fix malformed "Invalid Stream Identifier" error
      sctp: Select a working primary during sctp_connectx()
      sctp: Update SWS avaoidance receiver side algorithm
      sctp: Remove useless last_time_used variable
      sctp: Turn the enum socket options into defines
      sctp: Update max.burst implementation
      sctp: prevent too-fast association id reuse

Wei Yongjun (3):
      sctp: implement definition for SACK-IMMEDIATELY extension
      sctp: implement the receiver side for SACK-IMMEDIATELY extension
      sctp: implement the sender side for SACK-IMMEDIATELY extension

 Documentation/feature-removal-schedule.txt |   12 -
 include/linux/sctp.h                       |    1 +
 include/net/sctp/constants.h               |    4 +
 include/net/sctp/sm.h                      |    3 +-
 include/net/sctp/structs.h                 |   16 +-
 include/net/sctp/user.h                    |  132 ++++--------
 net/sctp/associola.c                       |   27 ++-
 net/sctp/chunk.c                           |   15 ++-
 net/sctp/output.c                          |   50 +---
 net/sctp/outqueue.c                        |   22 ++
 net/sctp/protocol.c                        |    3 +
 net/sctp/sm_make_chunk.c                   |   13 +-
 net/sctp/sm_sideeffect.c                   |    5 +-
 net/sctp/sm_statefuns.c                    |   26 ++-
 net/sctp/socket.c                          |  335 +---------------------------
 net/sctp/sysctl.c                          |   13 +
 net/sctp/transport.c                       |   45 ++++-
 17 files changed, 223 insertions(+), 499 deletions(-)

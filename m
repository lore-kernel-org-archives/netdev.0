From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: sctp pull request for net-next-2.6
Date: Fri, 30 Apr 2010 22:52:39 -0400
Message-ID: <4BDB9777.4020809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:10881 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754464Ab0EACwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 22:52:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

The following changes since commit 83d7eb2979cd3390c375470225dd2d8f2009bc70:
  Dan Carpenter (1):
        ipv6: cleanup: remove unneeded null check

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/vxy/lksctp-dev.git net-next

Dan Carpenter (1):
      sctp: cleanup: remove duplicate assignment

Shan Wei (1):
      sctp: use sctp_chunk_is_data macro to decide a chunk is data chunk

Vlad Yasevich (13):
      sctp: Use correct address family in sctp_getsockopt_peer_addrs()
      sctp: send SHUTDOWN-ACK chunk back to the source.
      sctp: Do no select unconfirmed transports for retransmissions
      sctp: Make sure we always return valid retransmit path
      sctp: remove 'resent' bit from the chunk
      sctp: Do not force T3 timer on fast retransmissions.
      sctp: Save some room in the sctp_transport by using bitfields
      sctp: update transport initializations
      sctp: fast recovery algorithm is per association.
      sctp: rwnd_press should be cumulative
      sctp: correctly mark missing chunks in fast recovery
      sctp: Optimize computation of highest new tsn in SACK.
      sctp: Tag messages that can be Nagle delayed at creation.

Wei Yongjun (5):
      sctp: assure at least one T3-rtx timer is running if a FORWARD TSN is sent
      sctp: discard ABORT chunk with zero verification tag in COOKIE-WAIT state
      sctp: missing set src and dest port while lookup output route
      sctp: fix to retranmit at least one DATA chunk
      sctp: implement sctp association probing module

 include/net/sctp/sctp.h    |    2 +-
 include/net/sctp/sm.h      |    2 +-
 include/net/sctp/structs.h |   66 +++++++-------
 net/sctp/Kconfig           |   12 +++
 net/sctp/Makefile          |    3 +
 net/sctp/associola.c       |   13 ++--
 net/sctp/chunk.c           |    4 +-
 net/sctp/endpointola.c     |    2 -
 net/sctp/output.c          |   27 ++----
 net/sctp/outqueue.c        |   94 +++++++++-----------
 net/sctp/probe.c           |  213 ++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/protocol.c        |    7 ++-
 net/sctp/sm_make_chunk.c   |   24 ++---
 net/sctp/sm_sideeffect.c   |    8 ++-
 net/sctp/socket.c          |    2 +-
 net/sctp/transport.c       |   61 ++++---------
 16 files changed, 364 insertions(+), 176 deletions(-)
 create mode 100644 net/sctp/probe.c


Please pull.
Thanks a lot
-vlad

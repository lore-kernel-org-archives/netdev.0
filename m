From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] Two SCTP cleanup patches
Date: Mon, 17 Jun 2013 11:40:03 +0200
Message-ID: <1371462005-19310-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754868Ab3FQJkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 05:40:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two cleanup-only patches to make the code more readable and consistent
with the rest of the kernel code.

Daniel Borkmann (2):
  net: sctp: get rid of t_new macro for kzalloc
  net: sctp: remove SCTP_STATIC macro

 include/net/sctp/sctp.h  | 11 -------
 net/sctp/associola.c     |  2 +-
 net/sctp/bind_addr.c     |  2 +-
 net/sctp/chunk.c         |  2 +-
 net/sctp/endpointola.c   |  3 +-
 net/sctp/input.c         |  4 +--
 net/sctp/ipv6.c          |  6 ++--
 net/sctp/protocol.c      |  6 ++--
 net/sctp/sm_make_chunk.c | 10 +++----
 net/sctp/socket.c        | 78 ++++++++++++++++++++++--------------------------
 net/sctp/transport.c     |  2 +-
 net/sctp/tsnmap.c        | 10 +++----
 net/sctp/ulpevent.c      | 10 +++----
 13 files changed, 64 insertions(+), 82 deletions(-)

-- 
1.7.11.7

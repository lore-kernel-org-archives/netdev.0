From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/21] tipc updates for the next round
Date: Tue, 10 May 2011 16:44:16 -0400
Message-ID: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52281 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab1EJUoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:44:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another mixed bag of tipc commits.  It leads off with some largely
cosmetic stuff, but then gets into what should be some more of the
useful/functional fixes with a bit more complexity.  There really
isn't any new functionality here -- just fixes or robustness type
improvements.

Paul.
---

The following changes since commit 7ef73bca731fea9d4b706db2acb96b6488aa1b0e:

  sctp: Fix debug message args. (2011-05-08 21:24:07 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-next-2.6.git tipc-May10-2011

Allan Stephens (19):
  tipc: Update comments in message header include file
  tipc: Eliminate unused routing message definitions
  tipc: Cosmetic consolidation of internal message type definitions
  tipc: Remove code to emulate loss of broadcast messages
  tipc: Don't initialize link selector field in fragmented messages
  tipc: Avoid pointless masking of fragmented message identifier
  tipc: Fix issues with fragmentation of an existing message buffer
  tipc: Set name lookup scope field properly in all data messages
  tipc: Fix problem with bundled multicast message
  tipc: Update destination node field on incoming multicast messages
  tipc: Fix sk_buff leaks when link congestion is detected
  tipc: Strengthen checks for neighboring node discovery
  tipc: Abort excessive send requests as early as possible
  tipc: Avoid recomputation of outgoing message length
  tipc: Introduce routine to enqueue a chain of messages on link tx queue
  tipc: Enhance handling of discovery object creation failures
  tipc: Enhance sending of discovery object link request messages
  tipc: Add monitoring of number of nodes discovered by bearer
  tipc: Revise timings used when sending link request messages

Michal Marek (1):
  tipc: Drop __TIME__ usage

Paul Gortmaker (1):
  tipc: make zone/cluster mask constants a define

 include/linux/tipc.h |    2 +-
 net/tipc/addr.h      |    7 ++-
 net/tipc/bcast.c     |   22 +-------
 net/tipc/bearer.c    |   45 +++++++++-----
 net/tipc/core.c      |    3 +-
 net/tipc/discover.c  |  150 +++++++++++++++++++++++++++++-----------------
 net/tipc/discover.h  |   11 ++--
 net/tipc/link.c      |  104 +++++++++++++++++++--------------
 net/tipc/link.h      |    1 +
 net/tipc/msg.c       |   25 +-------
 net/tipc/msg.h       |  161 +++++++++++++++++---------------------------------
 net/tipc/port.c      |   55 ++++++++++-------
 net/tipc/port.h      |   14 +++--
 net/tipc/socket.c    |   27 +++++++--
 net/tipc/subscr.c    |    4 +-
 15 files changed, 321 insertions(+), 310 deletions(-)

-- 
1.7.4.4


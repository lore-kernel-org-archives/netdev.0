From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 0/14] TIPC updates
Date: Fri, 13 Oct 2006 13:37:23 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Per Liden <per.liden@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:63371 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1751373AbWJMLh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:37:27 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This patch set includes a number TIPC fixes/cleanups. Please see each 
individual patch for further description.

Please pull from:

 git://tipc.cslab.ericsson.net/pub/git/tipc.git

 (rebased on linux/kernel/git/davem/net-2.6.git)

Summary:

 include/linux/tipc.h  |    1 
 net/tipc/bearer.c     |    8 +--
 net/tipc/config.c     |    5 +-
 net/tipc/core.c       |    4 +
 net/tipc/core.h       |   30 ++++++-----
 net/tipc/dbg.c        |  136 ++++++++++++++++++++++++++++++++-----------------
 net/tipc/dbg.h        |   15 +++++
 net/tipc/discover.c   |   39 +++++++++++++-
 net/tipc/link.c       |    8 +--
 net/tipc/name_distr.c |    2 -
 net/tipc/node.c       |    2 -
 net/tipc/port.c       |    7 ++-
 net/tipc/socket.c     |   53 +++++++++++++------
 net/tipc/subscr.c     |   99 ++++++++++++++++++++++++++++++------
 14 files changed, 296 insertions(+), 113 deletions(-)

Allan Stephens:
      [TIPC] Add missing unlock in port timeout code.
      [TIPC] Debug print buffer enhancements and fixes
      [TIPC] Stream socket can now send > 66000 bytes at a time
      [TIPC] Added duplicate node address detection capability
      [TIPC] Optimize wakeup logic when socket has no waiting processes
      [TIPC] Remove code bloat introduced by print buffer rework
      [TIPC] Add support for Ethernet VLANs
      [TIPC] Name publication events now delivered in chronological order
      [TIPC] Fixed slow link reactivation when link tolerance is large
      [TIPC] Can now list multicast link on an isolated network node
      [TIPC] Unrecognized configuration command now returns error message
      [TIPC] Updated TIPC version number to 1.6.2

Lijun Chen:
      [TIPC] Added subscription cancellation capability

P Litov:
      [TIPC] Fix socket receive queue NULL pointer dereference on SMP systems

/Per

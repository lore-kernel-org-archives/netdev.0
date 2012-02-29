From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/17] Another batch of TIPC commits for 3.4
Date: Wed, 29 Feb 2012 18:18:26 -0500
Message-ID: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53919 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965072Ab2B2XS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:18:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here is another round of commits for what will be the 3.4 release.
A good recurring theme here is simplify/remove/eliminate, and
the diffstat reflects that.

I've done the usual runtime testing between x86-32 and x86-64,
using the utils in the ptts dir of tipc-utils.

Thanks,
Paul.
---

The following changes since commit 7c3a95a15ad2a5278498a72df0463131048926a3:

  davinci_mdio: Correct bitmask for clock divider value (2012-02-24 03:24:18 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to 9bbbc59dbd4e69da078b65a7f708c4250984dd29:

  tipc: Optimize setting of immutable payload message header fields (2012-02-29 11:45:35 -0500)

----------------------------------------------------------------

Allan Stephens (16):
  tipc: Introduce node signature field in neighbor discovery message
  tipc: Detect duplicate nodes using different network interfaces
  tipc: Remove duplicate check of message destination node
  tipc: Simplify enforcement of reserved name type prohibition
  tipc: Add check to prevent insertion of duplicate name table entries
  tipc: Eliminate a test for negative unsigned quantities
  tipc: Hide internal details of node table implementation
  tipc: Eliminate trivial buffer manipulation helper routines
  tipc: Remove obsolete comments about routing table updates
  tipc: Minor optimization to broadcast link synchronization logic
  tipc: Revert name table translation optimization
  tipc: Eliminate obsolete support for "not running" mode
  tipc: Eliminate support for tipc_mode global variable
  tipc: Un-inline port routine for processing incoming messages
  tipc: Eliminate obsolete code for re-sending a message
  tipc: Optimize setting of immutable payload message header fields

Paul Gortmaker (1):
  tipc: nuke the delimit static inline function.

 net/tipc/bcast.c      |   12 ++--
 net/tipc/bearer.c     |    5 +-
 net/tipc/config.c     |   21 +++----
 net/tipc/core.c       |   10 ---
 net/tipc/core.h       |   42 ------------
 net/tipc/discover.c   |   79 ++++++++++++++++++-----
 net/tipc/link.c       |  173 ++++++++++++++++++++++++-------------------------
 net/tipc/log.c        |    2 +-
 net/tipc/msg.c        |    2 +-
 net/tipc/msg.h        |   15 +++--
 net/tipc/name_distr.c |    4 +-
 net/tipc/name_table.c |   48 ++++++--------
 net/tipc/name_table.h |    2 -
 net/tipc/net.c        |   11 +--
 net/tipc/node.c       |   70 +++++---------------
 net/tipc/node.h       |   19 ++----
 net/tipc/port.c       |   67 ++++++++++++++-----
 net/tipc/port.h       |   42 +------------
 net/tipc/socket.c     |   11 ++-
 net/tipc/subscr.c     |    2 +-
 20 files changed, 288 insertions(+), 349 deletions(-)

-- 
1.7.9.1

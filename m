From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/10] tipc: last batch from the sourceforge queue
Date: Mon, 30 Apr 2012 18:36:58 -0400
Message-ID: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <allan.stephens@windriver.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45974 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756383Ab2D3WhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 18:37:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I'm glad to say this represents the last batch of salvaged commits
from what was the sourceforge queue of stuff misplaced on the older
v2.6.19/v1.7.x baseline.  Going forward, folks got a clear message
that they _must_ put forward any new/prospective changes on netdev
for peer review and ask for continuous integration and not stockpile
crap in a corner (cause I'm sure as hell not going to volunteer to
be Winston Wolf for it again).

Anyway, knowing that there isn't any more "old" patches from that to
worry about, I took the opportunity to close out by clobbering a bunch
of needless extra blank lines following comments, since there isn't
any pending patch context fallout to worry about.  This one cosmetic
change alone makes up most of the diffstat, giving:

 32 files changed, 16 insertions(+), 530 deletions(-)

out of the total:

 34 files changed, 58 insertions(+), 567 deletions(-)


That aside, the meat of what is here is:

  -reduce some of the build up/tear down on configuration paths

  -more strict checks on published names and payload types

  -factor out some duplicated code;  +some redundant code deletion.

Testing has been the usual 64 <---> 32bit using tipc-utils ptts.

I still want to look at your suggestion of reusing existing code
for the logging stuff someday, now that the queue is closed out,
but that is completely separate from the backlog, and it probably
isn't going to be happening in the 3.5 timeframe.

Thanks,
Paul.
---

The following changes since commit 9cf6ace5f5c7981f5df76af3e1b90d77cc3cdece:

  mISDN: DSP scheduling fix (version 2) (2012-04-26 03:10:45 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to 617d3c7a50b3dc15f558d60013047aede79dc055:

  tipc: compress out gratuitous extra carriage returns (2012-04-30 15:53:56 -0400)

----------------------------------------------------------------

Allan Stephens (9):
  tipc: Optimize re-initialization of configuration service
  tipc: Optimize initialization of configuration service
  tipc: Optimize termination of configuration service
  tipc: Enhance re-initialization of network topology service
  tipc: Optimize initialization of network topology service
  tipc: remove redundant memset and stale comment from subscr.c
  tipc: Create helper routine to delete unused name sequence structure
  tipc: Enhance error checking of published names
  tipc: Reject payload messages with invalid message type

Paul Gortmaker (1):
  tipc: compress out gratuitous extra carriage returns

 net/tipc/Makefile      |    2 -
 net/tipc/addr.c        |    3 --
 net/tipc/addr.h        |    3 --
 net/tipc/bcast.c       |   22 ---------
 net/tipc/bcast.h       |    3 --
 net/tipc/bearer.c      |   22 +--------
 net/tipc/bearer.h      |    4 --
 net/tipc/config.c      |   28 ++++++-----
 net/tipc/config.h      |    1 +
 net/tipc/core.c        |   11 +----
 net/tipc/core.h        |   14 ------
 net/tipc/discover.c    |   14 ------
 net/tipc/eth_media.c   |   19 --------
 net/tipc/handler.c     |    1 -
 net/tipc/link.c        |  120 ++----------------------------------------------
 net/tipc/link.h        |    6 ---
 net/tipc/log.c         |   14 ------
 net/tipc/log.h         |    1 -
 net/tipc/msg.c         |    3 --
 net/tipc/msg.h         |   21 ---------
 net/tipc/name_distr.c  |   11 -----
 net/tipc/name_table.c  |   84 ++++++++++-----------------------
 net/tipc/name_table.h  |    3 --
 net/tipc/net.c         |    6 +--
 net/tipc/node.c        |   13 ------
 net/tipc/node.h        |    2 -
 net/tipc/node_subscr.c |    3 --
 net/tipc/node_subscr.h |    1 -
 net/tipc/port.c        |   37 +--------------
 net/tipc/port.h        |    3 --
 net/tipc/ref.c         |   13 ------
 net/tipc/socket.c      |   90 ++----------------------------------
 net/tipc/subscr.c      |   45 ------------------
 net/tipc/subscr.h      |    2 -
 34 files changed, 58 insertions(+), 567 deletions(-)

-- 
1.7.9.6

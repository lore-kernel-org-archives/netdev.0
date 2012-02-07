From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/15] TIPC updates for upcoming v3.4
Date: Mon,  6 Feb 2012 19:52:33 -0500
Message-ID: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50171 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab2BGAxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

No real trend or correlation from one patch to the next here,
just continued chiseling away at what were deemed to be the
worthwhile bits that were squirreled away on sourceforge.
I think there is on the order of 50 left after this.

I haven't forgot about your earlier request to see some of
the tipc_printbuf related stuff go away (at least I think that
was what you wanted to see replaced).  I'm not entirely 100%
sure how to proceed there just yet, so I may tackle a few
more from the remaining 50 in the interim while the log.c
cleanup gets more thought.

Runtime tested from 64 to 32 bit x86 machines; I had to revert
an skge commit to get my 32 bit machine functional, but that
is largely of no interest here.

Thanks,
Paul

---

The following changes since commit 3238a9be4d7ad95c741bcfe6c147406eeef62d95:

  cnic: Add FCoE parity error recovery (2012-02-05 22:42:00 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc_net-next

for you to fetch changes up to dff10e9e637663c8c5dd0bae1a8f0e899cbb4a36:

  tipc: Minor optimization to rejection of connection-based messages (2012-02-06 16:59:19 -0500)

----------------------------------------------------------------
Allan Stephens (15):
  tipc: improve the link deferred queue insertion algorithm
  tipc: Prevent transmission of outdated link protocol messages
  tipc: Prevent broadcast link stalling in dual LAN environments
  tipc: Ensure broadcast link re-acquires node after link failure
  tipc: Fix problem with broadcast link synchronization between nodes
  tipc: Add missing broadcast link lock when sending NACK
  tipc: Fix node lock reclamation issues in broadcast link reception
  tipc: Fix bug in broadcast link duplicate message statistics
  tipc: Add missing locks in broadcast link statistics accumulation
  tipc: Major redesign of broadcast link ACK/NACK algorithms
  tipc: Remove obsolete broadcast tag capability
  tipc: Prevent loss of fragmented messages over unicast links
  tipc: Prevent loss of fragmented messages over broadcast link
  tipc: Eliminate alteration of publication key during name table purging
  tipc: Minor optimization to rejection of connection-based messages

 net/tipc/bcast.c      |  324 +++++++++++++++++++++++-------------------------
 net/tipc/bcast.h      |    2 +-
 net/tipc/link.c       |  148 +++++++++++++----------
 net/tipc/name_distr.c |    4 -
 net/tipc/node.c       |   14 +--
 net/tipc/node.h       |   18 ++--
 net/tipc/port.c       |    5 +-
 7 files changed, 255 insertions(+), 260 deletions(-)

-- 
1.7.9

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/23] TIPC: Updates for what will be v3.3
Date: Tue, 27 Dec 2011 12:39:19 -0500
Message-ID: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39356 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612Ab1L0Rjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:39:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

Here are some more updates for TIPC, based on the backlog of stuff
that was unfortunately stacked away in sourceforge a while ago.

Given the timing, please feel free to defer these to the for-3.4
net-next if there isn't a convenient opportunity to process it
before 3.2 is officially released.  I can easily resend later.

Fortunately, the SF backlog will finally be 100% gone with the
pending stuff that will be sent in the next year for the 3.4
net-next, so that will be nice to have that task closed out.

I just finished testing this over the wire between an x86-32 and
an x86-64 box, with both taking turns being server and client.

Thanks,
Paul.

---
The following changes since commit 1ba9ac7c35b30d6b958a30240e21ddaea8d21b35:

  bonding: document undocumented active_slave sysfs entry. (2011-12-26 20:09:35 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git tipc-Dec27-2011

Allan Stephens (23):
  tipc: Enable use by containers having their own network namespace
  tipc: Register new media using pre-compiled structure
  tipc: Optimize detection of duplicate media registration
  tipc: Eliminate duplication of media structures
  tipc: Streamline media registration error checking
  tipc: Improve handling of media address printing errors
  tipc: Add new address conversion routines for Ethernet media
  tipc: Hide media-specific addressing details from generic bearer code
  tipc: Ignore neighbor discovery messages containing invalid address
  tipc: Allow run-time alteration of default link settings
  tipc: Revise comment justifying release of configuration spinlock
  tipc: Minor optimization to deactivation of Ethernet media suppot
  tipc: Do timely cleanup of disabled Ethernet bearer resources
  tipc: Eliminate useless memset operations in Ethernet media support
  tipc: Minor correction to TIPC module unloading
  tipc: Eliminate useless check when network address is assigned
  tipc: Eliminate dynamic allocation of broadcast link data structures
  tipc: Ensure broadcast link spinlock is held when updating node map
  tipc: Handle broadcast attempt when no neighboring nodes exist
  tipc: Minor optimization of broadcast link transmit queue statistic
  tipc: Flush unsent broadcast messages when contact with last node is lost
  tipc: Ignore broadcast acknowledgements that are out-of-range
  tipc: Allow use of buf_seqno() helper routine by unicast links

 net/tipc/bcast.c      |  125 +++++++++++++++++++------------
 net/tipc/bcast.h      |    6 +-
 net/tipc/bearer.c     |  158 ++++++++++++++-------------------------
 net/tipc/bearer.h     |   58 +++++++++------
 net/tipc/config.c     |   13 ++--
 net/tipc/core.c       |    2 +-
 net/tipc/discover.c   |    7 +-
 net/tipc/eth_media.c  |  159 ++++++++++++++++++++++++++++++----------
 net/tipc/link.c       |  195 ++++++++++++++++++++++++++++++++----------------
 net/tipc/link.h       |   11 +++
 net/tipc/msg.c        |    9 ++-
 net/tipc/msg.h        |   16 ++---
 net/tipc/name_distr.c |   12 +--
 net/tipc/net.c        |    7 +-
 net/tipc/node.c       |    7 +-
 net/tipc/socket.c     |    3 -
 16 files changed, 466 insertions(+), 322 deletions(-)

-- 
1.7.4.4

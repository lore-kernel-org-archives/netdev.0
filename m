From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sun, 27 Jul 2008 18:09:13 -0700 (PDT)
Message-ID: <20080727.180913.220698662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45234
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758240AbYG1BJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 21:09:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Some ipcomp warnings fixes and various DCCP bug fixes via
Gerrit Renker and co.

Sorry for the two merge changesets with your tree.  I did
one at the beginning several days ago, then we both merged
Al's sysctl fix, and I wanted to make sure that worked out
properly.

Please pull, thanks!

The following changes since commit c9272c4f9fbe2087beb3392f526dc5b19efaa56b:
  Linus Torvalds (1):
        Merge branch 'hotfixes' of git://git.linux-nfs.org/projects/trondmy/nfs-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Al Viro (1):
      net: missing bits of net-namespace / sysctl

David S. Miller (4):
      ipcomp: Fix warnings after ipcomp consolidation.
      Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.6
      Merge branch 'master' of git://eden-feed.erg.abdn.ac.uk/net-2.6
      Merge branch 'master' of master.kernel.org:/.../torvalds/linux-2.6

Gerrit Renker (2):
      dccp: Allow to distinguish original and retransmitted packets
      dccp: Bug-Fix - AWL was never updated

Wei Yongjun (4):
      dccp: Fix sequence number check for ICMPv4 packets
      dccp: Add check for sequence number in ICMPv6 message
      dccp: Fix incorrect length check for ICMPv4 packets
      dccp: Add check for truncated ICMPv6 DCCP error packets

 net/dccp/dccp.h    |    2 +-
 net/dccp/ipv4.c    |    9 ++++---
 net/dccp/ipv6.c    |   16 ++++++++++++++-
 net/dccp/output.c  |   53 ++++++++++++++++++++++++++++++---------------------
 net/dccp/timer.c   |   20 +++---------------
 net/ipv4/ipcomp.c  |    4 +--
 net/ipv6/ipcomp6.c |    4 +--
 7 files changed, 58 insertions(+), 50 deletions(-)

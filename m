From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking.
Date: Mon, 25 Aug 2008 15:44:34 -0700 (PDT)
Message-ID: <20080825.154434.253246969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753336AbYHYWoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 18:44:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Two sysctl fixes from Al Viro.

2) SCTP still had some holes in AUTH socket option handling,
   found by Eugene Teo and fixed by Vlad Yasevich.

3) BNX2X driver bug fixes from Eilon Greenstein and
   Yitchak Gertner.

   It says 220 lines changed in the diffstat but it's a
   set of 9 bug fixes which are mostly 4 liners.  If you
   still think this is pushing it I'll push back harder
   on the folks sending things to me, just let me know.

Otherwise, please pull, thanks a lot!

The following changes since commit f410a1fba7afa79d2992620e874a343fdba28332:
  Stephen Hemminger (1):
        ipv6: protocol for address routes

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Al Viro (2):
      ipv4: sysctl fixes
      ipv6: sysctl fixes

Eilon Greenstein (5):
      bnx2x: Rx work check
      bnx2x: Fan failure mechanism on additional design
      bnx2x: Minimize lock time
      bnx2x: HW lock timeout
      bnx2x: Version update

Vlad Yasevich (1):
      sctp: add verification checks to SCTP_AUTH_KEY option

Yitchak Gertner (4):
      bnx2x: Initialization structure
      bnx2x: NIC load failure cleanup
      bnx2x: NAPI and interrupts enable/disable
      bnx2x: Multi Queue

 drivers/net/bnx2x.h        |    2 +-
 drivers/net/bnx2x_main.c   |  220 ++++++++++++++++++++++---------------------
 net/ipv4/route.c           |   24 ++++-
 net/ipv6/sysctl_net_ipv6.c |    2 +-
 net/sctp/auth.c            |    4 +
 net/sctp/socket.c          |    5 +
 6 files changed, 144 insertions(+), 113 deletions(-)

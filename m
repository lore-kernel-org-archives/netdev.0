From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/2] Duplication of #define with mii.h.
Date: Thu, 25 Aug 2011 11:20:19 +0200
Message-ID: <20110825092019.GA21777@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57430 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab1HYJiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 05:38:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.mii' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem-next.mii

to get the changes below.

The sunbmac changes are not compile tested. Sunbmac changeset is on top of the
stack so it can be instantly removed if untrusted. Building a packaged rpm for a
cross sparc-linux compiler quickly turned more interesting than expected.

Distance from 'davem-next' (0856a304091b33a8e8f9f9c98e776f425af2b625)
---------------------------------------------------------------------

cd2967803617cd0a0bb8611e7d41c33a451207a5
78f6a6bd89e9a33e4be1bc61e6990a1172aa396e

Diffstat
--------

 drivers/net/ethernet/dlink/dl2k.c  |  105 +++++++++++++++++------------------
 drivers/net/ethernet/dlink/dl2k.h  |  110 +-----------------------------------
 drivers/net/ethernet/sun/sunbmac.c |   31 +++++-----
 drivers/net/ethernet/sun/sunbmac.h |   17 ------
 4 files changed, 69 insertions(+), 194 deletions(-)

Shortlog
--------

Francois Romieu (2):
      dl2k: use standard #defines from mii.h.
      sunbmac: use standard #defines from mii.h.

Patch
-----

See patches #1 and #2.

-- 
Ueimor

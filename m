From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] r8169: fix wrong register use.
Date: Fri, 24 Jun 2011 19:49:44 +0200
Message-ID: <20110624174944.GA3700@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53581 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab1FXSDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 14:03:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem.r8169' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem.r8169

to get the change below.

@Hayes: version 8.023.00 of Realtek's r8168 driver has the same problem.

Distance from 'davem' (5c18e80be9ff362f6523b097d495bb2e2f939946)
----------------------------------------------------------------

1e4e82baee8c2a8d753cbf6aa1a77326b71e59f0

Diffstat
--------

 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

Shortlog
--------

Francois Romieu (1):
      r8169: fix wrong register use.

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 05d8178..5990621 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -742,7 +742,7 @@ static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 	msleep(2);
 	for (i = 0; i < 5; i++) {
 		udelay(100);
-		if (!(RTL_R32(ERIDR) & ERIAR_FLAG))
+		if (!(RTL_R32(ERIAR) & ERIAR_FLAG))
 			break;
 	}
 
-- 
Ueimor

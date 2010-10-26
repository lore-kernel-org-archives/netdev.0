From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 3/5] netdev: bfin_mac: drop unused Mac data
Date: Tue, 26 Oct 2010 03:40:25 -0400
Message-ID: <1288078827-17495-3-git-send-email-vapier@gentoo.org>
References: <1288078827-17495-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38823 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994Ab0JZHkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 03:40:21 -0400
In-Reply-To: <1288078827-17495-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't use this local "Mac" data anywhere (since we rely on the
netdev's storage), so punt it.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index aed68be..4827f6b 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -68,7 +68,6 @@ struct bfin_mac_local {
 	 */
 	struct net_device_stats stats;
 
-	unsigned char Mac[6];	/* MAC address of the board */
 	spinlock_t lock;
 
 	int wol;		/* Wake On Lan */
-- 
1.7.3.2


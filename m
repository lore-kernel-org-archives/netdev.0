From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 2/5] netdev: bfin_mac: mark setup_system_regs as static
Date: Tue, 26 Oct 2010 03:40:24 -0400
Message-ID: <1288078827-17495-2-git-send-email-vapier@gentoo.org>
References: <1288078827-17495-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38820 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752555Ab0JZHkU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 03:40:20 -0400
In-Reply-To: <1288078827-17495-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need for this to be exported since it is only used in this driver.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index a572bcb..e712be4 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -558,7 +558,7 @@ static const struct ethtool_ops bfin_mac_ethtool_ops = {
 };
 
 /**************************************************************************/
-void setup_system_regs(struct net_device *dev)
+static void setup_system_regs(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	int i;
-- 
1.7.3.2


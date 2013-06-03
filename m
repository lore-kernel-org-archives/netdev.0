From: Yan Burman <yanb@mellanox.com>
Subject: [PATCH net-next] net/ethtool: Fix comment regarding location of dev_ethtool() call
Date: Mon,  3 Jun 2013 15:03:34 +0300
Message-ID: <1370261014-16153-1-git-send-email-yanb@mellanox.com>
Cc: Yan Burman <yanb@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44895 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752716Ab3FCMKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 08:10:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yan Burman <yanb@mellanox.com>
---
 net/core/ethtool.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 4e6f63a..cd23d31 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1414,7 +1414,7 @@ static int ethtool_get_module_eeprom(struct net_device *dev,
 				      modinfo.eeprom_len);
 }
 
-/* The main entry point in this file.  Called from net/core/dev.c */
+/* The main entry point in this file.  Called from net/core/dev_ioctl.c */
 
 int dev_ethtool(struct net *net, struct ifreq *ifr)
 {
-- 
1.7.10.1

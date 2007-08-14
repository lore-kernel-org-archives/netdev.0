From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport dev_ethtool
Date: Tue, 14 Aug 2007 23:22:03 +0200
Message-ID: <20070814212203.GV18945@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:38397 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753523AbXHNVWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 17:22:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the no longer used EXPORT_SYMBOL(dev_ethtool).

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
37bcb29c1a1fefe6da0ea9e54a5cde09a82318f0 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 2ab0a60..c5e0593 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -948,7 +948,6 @@ int dev_ethtool(struct ifreq *ifr)
 	return rc;
 }
 
-EXPORT_SYMBOL(dev_ethtool);
 EXPORT_SYMBOL(ethtool_op_get_link);
 EXPORT_SYMBOL(ethtool_op_get_sg);
 EXPORT_SYMBOL(ethtool_op_get_tso);


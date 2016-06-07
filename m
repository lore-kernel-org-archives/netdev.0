From: Fabien Siron <fabien.siron@epita.fr>
Subject: [PATCH] net/netlink/af_netlink.h: Remove unused structure.
Date: Tue, 7 Jun 2016 13:02:04 +0000
Message-ID: <20160607130204.414-1-fabien.siron@epita.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	Fabien Siron <fabien.siron@epita.fr>
To: <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0062.outbound.protection.outlook.com ([157.56.112.62]:31376
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754069AbcFGNC1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 09:02:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabien Siron <fabien.siron@epita.fr>
---
 net/netlink/af_netlink.h | 14 --------------
 1 file changed, 14 deletions(-)

diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index e68ef9c..3cfd6cc 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -8,20 +8,6 @@
 #define NLGRPSZ(x)	(ALIGN(x, sizeof(unsigned long) * 8) / 8)
 #define NLGRPLONGS(x)	(NLGRPSZ(x)/sizeof(unsigned long))
 
-struct netlink_ring {
-	void			**pg_vec;
-	unsigned int		head;
-	unsigned int		frames_per_block;
-	unsigned int		frame_size;
-	unsigned int		frame_max;
-
-	unsigned int		pg_vec_order;
-	unsigned int		pg_vec_pages;
-	unsigned int		pg_vec_len;
-
-	atomic_t		pending;
-};
-
 struct netlink_sock {
 	/* struct sock has to be the first member of netlink_sock */
 	struct sock		sk;
-- 
2.8.3

From: "John W. Linville" <linville@tuxdriver.com>
Subject: [RFC PATCH 1/5] geneve: remove MODULE_ALIAS_RTNL_LINK from net/ipv4/geneve.c
Date: Thu,  2 Apr 2015 15:17:02 -0400
Message-ID: <1428002227-11636-2-git-send-email-linville@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49881 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbbDBTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 15:19:13 -0400
In-Reply-To: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file is essentially a library for implementing the geneve
encapsulation protocol.  The file does not register any rtnl_link_ops,
so the MODULE_ALIAS_RTNL_LINK macro is inappropriate here.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/ipv4/geneve.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 5a4828ba05ad..ba5283adbee8 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -450,4 +450,3 @@ module_exit(geneve_cleanup_module);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
 MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
-MODULE_ALIAS_RTNL_LINK("geneve");
-- 
2.1.0

From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v3 1/5] geneve: remove MODULE_ALIAS_RTNL_LINK from net/ipv4/geneve.c
Date: Wed, 13 May 2015 12:57:26 -0400
Message-ID: <1431536250-14760-2-git-send-email-linville@tuxdriver.com>
References: <1431536250-14760-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36518 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932380AbbEMRAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 13:00:18 -0400
In-Reply-To: <1431536250-14760-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This file is essentially a library for implementing the geneve
encapsulation protocol.  The file does not register any rtnl_link_ops,
so the MODULE_ALIAS_RTNL_LINK macro is inappropriate here.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
v2: skipped
v3: repost complete series for clarity

 net/ipv4/geneve.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
index 8986e63f3bda..8e6a7fe27a4c 100644
--- a/net/ipv4/geneve.c
+++ b/net/ipv4/geneve.c
@@ -450,4 +450,3 @@ module_exit(geneve_cleanup_module);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
 MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
-MODULE_ALIAS_RTNL_LINK("geneve");
-- 
2.1.0

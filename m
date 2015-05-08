From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 4/5] geneve_core: identify as driver library in modules description
Date: Fri,  8 May 2015 13:20:56 -0400
Message-ID: <1431105657-25492-5-git-send-email-linville@tuxdriver.com>
References: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49269 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932483AbbEHRWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 13:22:11 -0400
In-Reply-To: <1431105657-25492-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/ipv4/geneve_core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/geneve_core.c b/net/ipv4/geneve_core.c
index 001843d41135..311a4ba6950a 100644
--- a/net/ipv4/geneve_core.c
+++ b/net/ipv4/geneve_core.c
@@ -430,7 +430,7 @@ static int __init geneve_init_module(void)
 	if (rc)
 		return rc;
 
-	pr_info("Geneve driver\n");
+	pr_info("Geneve core logic\n");
 
 	return 0;
 }
@@ -444,4 +444,4 @@ module_exit(geneve_cleanup_module);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
-MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
+MODULE_DESCRIPTION("Driver library for GENEVE encapsulated traffic");
-- 
2.1.0

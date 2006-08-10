From: Patrick McHardy <kaber@trash.net>
Subject: [NET 06/06]: Increate RT_TABLE_MAX to 2^32
Date: Thu, 10 Aug 2006 21:30:06 +0200 (MEST)
Message-ID: <20060810193006.14867.57446.sendpatchset@localhost.localdomain>
References: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46810 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932114AbWHJTaH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 15:30:07 -0400
To: davem@davemloft.net
In-Reply-To: <20060810192957.14867.71965.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Increate RT_TABLE_MAX to 2^32

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f20cbb83204cd7e2ffa9cf4e8ee8b6353628d5d3
tree 8f0eaa4219506715449e7118037040f396875c99
parent 9203e4cdab89d96c474c6a903ef9a1f47c7eee07
author Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:54:49 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 10 Aug 2006 20:54:49 +0200

 include/linux/rtnetlink.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index b01bc8b..a616c68 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -239,10 +239,8 @@ enum rt_class_t
 	RT_TABLE_DEFAULT=253,
 	RT_TABLE_MAIN=254,
 	RT_TABLE_LOCAL=255,
-	__RT_TABLE_MAX
+	RT_TABLE_MAX=0xFFFFFFFF
 };
-#define RT_TABLE_MAX (__RT_TABLE_MAX - 1)
-
 
 
 /* Routing message attributes */

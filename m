From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Get rid of compat defines in psock_fanout.c selftest.
Date: Tue, 19 Mar 2013 18:09:08 -0400 (EDT)
Message-ID: <20130319.180908.677353451395965998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49238 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933133Ab3CSWJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 18:09:09 -0400
Received: from localhost (cpe-66-108-118-205.nyc.res.rr.com [66.108.118.205])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 51B94581241
	for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 15:09:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reported-by: Daniel Baluta <dbaluta@ixiacom.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/testing/selftests/net-afpacket/psock_fanout.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/tools/testing/selftests/net-afpacket/psock_fanout.c b/tools/testing/selftests/net-afpacket/psock_fanout.c
index 09dbf93..af9b019 100644
--- a/tools/testing/selftests/net-afpacket/psock_fanout.c
+++ b/tools/testing/selftests/net-afpacket/psock_fanout.c
@@ -56,24 +56,6 @@
 #include <sys/types.h>
 #include <unistd.h>
 
-/* Hack: build even if local includes are old */
-#ifndef PACKET_FANOUT
-#define PACKET_FANOUT			18
-#define PACKET_FANOUT_HASH		0
-#define PACKET_FANOUT_LB		1
-#define PACKET_FANOUT_CPU		2
-#define PACKET_FANOUT_FLAG_DEFRAG	0x8000
-
-#ifndef PACKET_FANOUT_ROLLOVER
-#define PACKET_FANOUT_ROLLOVER		3
-#endif
-
-#ifndef PACKET_FANOUT_FLAG_ROLLOVER
-#define PACKET_FANOUT_FLAG_ROLLOVER	0x1000
-#endif
-
-#endif
-
 #define DATA_LEN			100
 #define DATA_CHAR			'a'
 
-- 
1.7.11.7

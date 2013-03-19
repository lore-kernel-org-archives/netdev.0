From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Fix failure string in net-socket selftests Makefile.
Date: Tue, 19 Mar 2013 17:16:56 -0400 (EDT)
Message-ID: <20130319.171656.2169297554900450866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48596 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933560Ab3CSVQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 17:16:57 -0400
Received: from localhost (cpe-66-108-118-205.nyc.res.rr.com [66.108.118.205])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 8BE3F581157
	for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 14:17:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 tools/testing/selftests/net-socket/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/net-socket/Makefile b/tools/testing/selftests/net-socket/Makefile
index f27ee10..2450fd8 100644
--- a/tools/testing/selftests/net-socket/Makefile
+++ b/tools/testing/selftests/net-socket/Makefile
@@ -10,7 +10,7 @@ all: $(NET_SOCK_PROGS)
 	$(CC) $(CFLAGS) -o $@ $^
 
 run_tests: all
-	@/bin/sh ./run_netsocktests || echo "vmtests: [FAIL]"
+	@/bin/sh ./run_netsocktests || echo "sockettests: [FAIL]"
 
 clean:
 	$(RM) $(NET_SOCK_PROGS)
-- 
1.7.11.7

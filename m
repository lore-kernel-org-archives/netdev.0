From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 RESEND] lib: rhashtable: remove second linux/log2.h inclusion
Date: Wed, 17 Sep 2014 21:07:19 +0200
Message-ID: <1410980839-5809-1-git-send-email-fabf@skynet.be>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Fabian Frederick <fabf@skynet.be>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay006.isp.belgacom.be ([195.238.6.172]:58765 "EHLO
	mailrelay006.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756309AbaIQTI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 15:08:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux/log2.h was included twice.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 lib/rhashtable.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index a2c7881..7b36e4d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -23,7 +23,6 @@
 #include <linux/hash.h>
 #include <linux/random.h>
 #include <linux/rhashtable.h>
-#include <linux/log2.h>
 
 #define HASH_DEFAULT_SIZE	64UL
 #define HASH_MIN_SIZE		4UL
-- 
2.1.0

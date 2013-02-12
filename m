From: pablo@netfilter.org
Subject: [PATCH] checksum: remove duplicated line of code in csum_fold
Date: Tue, 12 Feb 2013 18:10:03 +0100
Message-ID: <1360689003-21794-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, Arnd Bergmann <arnd@arndb.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:39558 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932327Ab3BLRKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 12:10:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/asm-generic/checksum.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/include/asm-generic/checksum.h b/include/asm-generic/checksum.h
index c084767..f68b2ea 100644
--- a/include/asm-generic/checksum.h
+++ b/include/asm-generic/checksum.h
@@ -51,7 +51,6 @@ static inline __sum16 csum_fold(__wsum csum)
 {
 	u32 sum = (__force u32)csum;
 	sum = (sum & 0xffff) + (sum >> 16);
-	sum = (sum & 0xffff) + (sum >> 16);
 	return (__force __sum16)~sum;
 }
 
-- 
1.7.10.4

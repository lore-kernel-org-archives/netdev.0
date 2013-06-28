From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: Swap ver and type in pppoe_hdr
Date: Sat, 29 Jun 2013 00:15:51 +0800
Message-ID: <1372436151-61527-1-git-send-email-xiaosuo@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:63419 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753912Ab3F1QQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:16:56 -0400
Received: by mail-pa0-f44.google.com with SMTP id lj1so2612605pab.3
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 09:16:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ver and type in pppoe_hdr should be swapped as defined by RFC2516
section-4.
---
 include/uapi/linux/if_pppox.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_pppox.h b/include/uapi/linux/if_pppox.h
index 0b46fd5..e36a4ae 100644
--- a/include/uapi/linux/if_pppox.h
+++ b/include/uapi/linux/if_pppox.h
@@ -135,11 +135,11 @@ struct pppoe_tag {
 
 struct pppoe_hdr {
 #if defined(__LITTLE_ENDIAN_BITFIELD)
-	__u8 ver : 4;
 	__u8 type : 4;
+	__u8 ver : 4;
 #elif defined(__BIG_ENDIAN_BITFIELD)
-	__u8 type : 4;
 	__u8 ver : 4;
+	__u8 type : 4;
 #else
 #error	"Please fix <asm/byteorder.h>"
 #endif
-- 
1.7.9.5

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 1/6] net-tc: remove unused tc_verd fields
Date: Sat,  7 Jan 2017 17:06:33 -0500
Message-ID: <20170107220638.61314-2-willemdebruijn.kernel@gmail.com>
References: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35619 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932673AbdAGWGn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 17:06:43 -0500
Received: by mail-qk0-f193.google.com with SMTP id u25so66743810qki.2
        for <netdev@vger.kernel.org>; Sat, 07 Jan 2017 14:06:42 -0800 (PST)
In-Reply-To: <20170107220638.61314-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Remove the last reference to tc_verd's munge and redirect ttl bits.
These fields are no longer used.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/pkt_cls.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index cb4bcdc58543..c769f71972f5 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -17,10 +17,6 @@
 
 /* verdict bit breakdown 
  *
-bit 0: when set -> this packet has been munged already
-
-bit 1: when set -> It is ok to munge this packet
-
 bit 2,3,4,5: Reclassify counter - sort of reverse TTL - if exceeded
 assume loop
 
@@ -31,8 +27,6 @@ bit 6,7: Where this packet was last seen
 
 bit 8: when set --> Request not to classify on ingress. 
 
-bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
-
  *
  * */
 
@@ -56,7 +50,6 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define SET_TC_AT(v,n)   ((V_TC_AT(n)) | (v & ~M_TC_AT))
 
 #define MAX_REC_LOOP 4
-#define MAX_RED_LOOP 4
 #endif
 
 /* Action attributes */
-- 
2.11.0.390.gc69c2f50cf-goog

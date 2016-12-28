From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next rfc 1/6] net-tc: remove unused tc_verd fields
Date: Wed, 28 Dec 2016 14:13:25 -0500
Message-ID: <1482952410-50003-2-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, dborkman@iogearbox.net,
        jhs@mojatatu.com, alexei.starovoitov@gmail.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33929 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751878AbcL1TNe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:13:34 -0500
Received: by mail-qt0-f193.google.com with SMTP id p16so24897514qta.1
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2016 11:13:33 -0800 (PST)
In-Reply-To: <1482952410-50003-1-git-send-email-willemdebruijn.kernel@gmail.com>
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
index cb4bcdc..c769f71 100644
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
2.8.0.rc3.226.g39d4020

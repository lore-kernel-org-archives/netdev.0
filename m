From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [iproute2 PATCH] tc/mirred: Clean up white-space noise
Date: Wed, 13 Sep 2017 03:05:13 -0700
Message-ID: <150529711361.57333.10151730051655064515.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, amritha.nambiar@intel.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22614 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751542AbdIMKGW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 13 Sep 2017 06:06:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 include/linux/tc_act/tc_mirred.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/tc_act/tc_mirred.h b/include/linux/tc_act/tc_mirred.h
index 3d7a2b3..69038c2 100644
--- a/include/linux/tc_act/tc_mirred.h
+++ b/include/linux/tc_act/tc_mirred.h
@@ -9,13 +9,13 @@
 #define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
 #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
 #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
-                                                                                
+
 struct tc_mirred {
 	tc_gen;
 	int                     eaction;   /* one of IN/EGRESS_MIRROR/REDIR */
 	__u32                   ifindex;  /* ifindex of egress port */
 };
-                                                                                
+
 enum {
 	TCA_MIRRED_UNSPEC,
 	TCA_MIRRED_TM,
@@ -24,5 +24,5 @@ enum {
 	__TCA_MIRRED_MAX
 };
 #define TCA_MIRRED_MAX (__TCA_MIRRED_MAX - 1)
-                                                                                
+
 #endif

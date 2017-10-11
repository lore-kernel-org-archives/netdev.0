From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] sched: tc_mirred: Remove whitespaces
Date: Wed, 11 Oct 2017 11:14:49 -0700
Message-ID: <20171011181450.22648-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This file contains unnecessary whitespaces as newlines, remove them,
found by looking at what struct tc_mirred looks like.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/uapi/linux/tc_act/tc_mirred.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/tc_act/tc_mirred.h b/include/uapi/linux/tc_act/tc_mirred.h
index 3d7a2b352a62..69038c29e8a9 100644
--- a/include/uapi/linux/tc_act/tc_mirred.h
+++ b/include/uapi/linux/tc_act/tc_mirred.h
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
-- 
2.9.3

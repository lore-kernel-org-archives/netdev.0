From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH 1/3] net/sched: Introduce the user API for the CBS shaper
Date: Tue, 26 Sep 2017 16:39:14 -0700
Message-ID: <20170926233916.11774-2-vinicius.gomes@intel.com>
References: <20170926233916.11774-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:16227 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031350AbdIZXjf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 19:39:35 -0400
In-Reply-To: <20170926233916.11774-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export the API necessary for configuring the CBS shaper (implemented
in the next patch) via the tc tool.

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
---
 include/uapi/linux/pkt_sched.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 099bf5528fed..27c849c053cf 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -871,4 +871,21 @@ struct tc_pie_xstats {
 	__u32 maxq;             /* maximum queue size */
 	__u32 ecn_mark;         /* packets marked with ecn*/
 };
+
+/* CBS */
+struct tc_cbs_qopt {
+	__s32 hicredit;
+	__s32 locredit;
+	__s32 idleslope;
+	__s32 sendslope;
+};
+
+enum {
+	TCA_CBS_UNSPEC,
+	TCA_CBS_PARMS,
+	__TCA_CBS_MAX,
+};
+
+#define TCA_CBS_MAX (__TCA_CBS_MAX - 1)
+
 #endif
-- 
2.14.2

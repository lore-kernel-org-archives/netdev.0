From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [next-queue PATCH v2 3/5] net/sched: Introduce the user API for the CBS shaper
Date: Fri, 29 Sep 2017 17:26:55 -0700
Message-ID: <20170930002657.15291-4-vinicius.gomes@intel.com>
References: <20170930002657.15291-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50320 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752592AbdI3A13 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:27:29 -0400
In-Reply-To: <20170930002657.15291-1-vinicius.gomes@intel.com>
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

From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [RFC iproute2 1/2] update headers with CBS API [RFC]
Date: Thu, 31 Aug 2017 18:26:45 -0700
Message-ID: <20170901012646.14939-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:15457 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751237AbdIAB06 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 21:26:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
---
 include/linux/pkt_sched.h | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 099bf552..ba6c9a54 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -871,4 +871,33 @@ struct tc_pie_xstats {
 	__u32 maxq;             /* maximum queue size */
 	__u32 ecn_mark;         /* packets marked with ecn*/
 };
+
+/* CBS */
+/* FIXME: this is only for usage with ndo_setup_tc(), this should be
+ * in another header someplace else. Is pkt_cls.h the right place?
+ */
+struct tc_cbs_qopt_offload {
+	__u8		enable;
+	__s32		queue;
+	__s32		hicredit;
+	__s32		locredit;
+	__s32		idleslope;
+	__s32		sendslope;
+};
+
+struct tc_cbs_qopt {
+	__s32		hicredit;
+	__s32		locredit;
+	__s32		idleslope;
+	__s32		sendslope;
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
2.14.1

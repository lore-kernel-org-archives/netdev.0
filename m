From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: [iproute2 net-next v2 1/3] update headers with CBS API [ONLY FOR TESTING]
Date: Tue, 10 Oct 2017 17:46:50 -0700
Message-ID: <20171011004652.15630-1-vinicius.gomes@intel.com>
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39663 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932892AbdJKArI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 20:47:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The headers will be updated when iproute2 fetches the headers from
net-next, this patch is only to ease testing.

Signed-off-by: Vinicius Costa Gomes <vinicius.gomes@intel.com>
---
 include/linux/pkt_sched.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 099bf552..41e349df 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -871,4 +871,22 @@ struct tc_pie_xstats {
 	__u32 maxq;             /* maximum queue size */
 	__u32 ecn_mark;         /* packets marked with ecn*/
 };
+
+/* CBS */
+struct tc_cbs_qopt {
+	__u8 offload;
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

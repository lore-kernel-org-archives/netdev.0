From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/16] PKT_SCHED: Max TLV types cleanup
Date: Thu, 21 Oct 2004 14:34:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021123452.GG21977@postel.suug.ch>
References: <20041021123209.GE21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041021123209.GE21977@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleans up maximum TLV type of existing definitions and adds
missing definitions for TBF, RED, GRED, and HTB.

Signed-off-by: Thomas Graf <tgraf@suug.ch>


--- linux-2.6.9-rc5.orig/include/linux/pkt_sched.h	2004-10-21 10:44:39.000000000 +0200
+++ linux-2.6.9-rc5/include/linux/pkt_sched.h	2004-10-21 11:09:53.000000000 +0200
@@ -117,8 +117,11 @@
 	TCA_TBF_PARMS,
 	TCA_TBF_RTAB,
 	TCA_TBF_PTAB,
+	__TCA_TBF_MAX,
 };
 
+#define TCA_TBF_MAX (__TCA_TBF_MAX - 1)
+
 
 /* TEQL section */
 
@@ -151,8 +154,11 @@
 	TCA_RED_UNSPEC,
 	TCA_RED_PARMS,
 	TCA_RED_STAB,
+	__TCA_RED_MAX,
 };
 
+#define TCA_RED_MAX (__TCA_RED_MAX - 1)
+
 struct tc_red_qopt
 {
 	__u32		limit;		/* HARD maximal queue length (bytes)	*/
@@ -183,8 +189,11 @@
        TCA_GRED_PARMS,
        TCA_GRED_STAB,
        TCA_GRED_DPS,
+	   __TCA_GRED_MAX,
 };
 
+#define TCA_GRED_MAX (__TCA_GRED_MAX - 1)
+
 #define TCA_SET_OFF TCA_GRED_PARMS
 struct tc_gred_qopt
 {
@@ -249,7 +258,11 @@
 	TCA_HTB_INIT,
 	TCA_HTB_CTAB,
 	TCA_HTB_RTAB,
+	__TCA_HTB_MAX,
 };
+
+#define TCA_HTB_MAX (__TCA_HTB_MAX - 1)
+
 struct tc_htb_xstats
 {
 	__u32 lends;
@@ -287,9 +300,12 @@
 	TCA_HFSC_RSC,
 	TCA_HFSC_FSC,
 	TCA_HFSC_USC,
-	TCA_HFSC_MAX = TCA_HFSC_USC
+	__TCA_HFSC_MAX,
 };
 
+#define TCA_HFSC_MAX (__TCA_HFSC_MAX - 1)
+
+
 /* CBQ section */
 
 #define TC_CBQ_MAXPRIO		8
@@ -370,9 +386,10 @@
 	TCA_CBQ_RATE,
 	TCA_CBQ_RTAB,
 	TCA_CBQ_POLICE,
+	__TCA_CBQ_MAX,
 };
 
-#define TCA_CBQ_MAX	TCA_CBQ_POLICE
+#define TCA_CBQ_MAX	(__TCA_CBQ_MAX - 1)
 
 /* dsmark section */
 
@@ -382,10 +399,11 @@
 	TCA_DSMARK_DEFAULT_INDEX,
 	TCA_DSMARK_SET_TC_INDEX,
 	TCA_DSMARK_MASK,
-	TCA_DSMARK_VALUE
+	TCA_DSMARK_VALUE,
+	__TCA_DSMARK_MAX,
 };
 
-#define TCA_DSMARK_MAX TCA_DSMARK_VALUE
+#define TCA_DSMARK_MAX (__TCA_DSMARK_MAX - 1)
 
 /* ATM  section */
 
@@ -396,10 +414,11 @@
 	TCA_ATM_HDR,		/* LL header */
 	TCA_ATM_EXCESS,		/* excess traffic class (0 for CLP)  */
 	TCA_ATM_ADDR,		/* PVC address (for output only) */
-	TCA_ATM_STATE		/* VC state (ATM_VS_*; for output only) */
+	TCA_ATM_STATE,		/* VC state (ATM_VS_*; for output only) */
+	__TCA_ATM_MAX,
 };
 
-#define TCA_ATM_MAX	TCA_ATM_STATE
+#define TCA_ATM_MAX	(__TCA_ATM_MAX - 1)
 
 /* Network emulator */
 
@@ -408,9 +427,10 @@
 	TCA_NETEM_UNSPEC,
 	TCA_NETEM_CORR,
 	TCA_NETEM_DELAY_DIST,
+	__TCA_NETEM_MAX,
 };
 
-#define TCA_NETEM_MAX	TCA_NETEM_DELAY_DIST
+#define TCA_NETEM_MAX (__TCA_NETEM_MAX - 1)
 
 struct tc_netem_qopt
 {

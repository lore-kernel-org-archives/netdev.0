From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/2] HFSC: Fix indentations
Date: Thu, 18 Mar 2004 17:46:41 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4059D271.2080705@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070304050700070807040206"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070304050700070807040206
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Dave,

this patch fixes broken indentations in HFSC from the u_intXX_t -> uXX 
change.

Best regards
Patrick

--------------070304050700070807040206
Content-Type: text/x-patch;
 name="01-hfsc-indent.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01-hfsc-indent.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/03/17 03:01:46+01:00 kaber@trash.net 
#   [NET_SCHED}: Fix indentations in HFSC scheduler
# 
# net/sched/sch_hfsc.c
#   2004/03/17 03:01:37+01:00 kaber@trash.net +17 -20
#   [NET_SCHED}: Fix indentations in HFSC scheduler
# 
diff -Nru a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
--- a/net/sched/sch_hfsc.c	Thu Mar 18 02:34:11 2004
+++ b/net/sched/sch_hfsc.c	Thu Mar 18 02:34:11 2004
@@ -118,7 +118,7 @@
 
 struct hfsc_class
 {
-	u32	classid;	/* class id */
+	u32		classid;	/* class id */
 	unsigned int	refcnt;		/* usage count */
 
 	struct tc_stats	stats;		/* generic statistics */
@@ -138,28 +138,28 @@
 	struct list_head hlist;		/* hash list member */
 	struct list_head dlist;		/* drop list member */
 
-	u64	cl_total;	/* total work in bytes */
-	u64	cl_cumul;	/* cumulative work in bytes done by
+	u64	cl_total;		/* total work in bytes */
+	u64	cl_cumul;		/* cumulative work in bytes done by
 					   real-time criteria */
 
-	u64 	cl_d;		/* deadline*/
-	u64 	cl_e;		/* eligible time */
-	u64	cl_vt;		/* virtual time */
-	u64	cl_f;		/* time when this class will fit for
+	u64 	cl_d;			/* deadline*/
+	u64 	cl_e;			/* eligible time */
+	u64	cl_vt;			/* virtual time */
+	u64	cl_f;			/* time when this class will fit for
 					   link-sharing, max(myf, cfmin) */
-	u64	cl_myf;		/* my fit-time (calculated from this
+	u64	cl_myf;			/* my fit-time (calculated from this
 					   class's own upperlimit curve) */
-	u64	cl_myfadj;	/* my fit-time adjustment (to cancel
+	u64	cl_myfadj;		/* my fit-time adjustment (to cancel
 					   history dependence) */
-	u64	cl_cfmin;	/* earliest children's fit-time (used
+	u64	cl_cfmin;		/* earliest children's fit-time (used
 					   with cl_myf to obtain cl_f) */
-	u64	cl_cvtmin;	/* minimal virtual time among the
+	u64	cl_cvtmin;		/* minimal virtual time among the
 					   children fit for link-sharing
 					   (monotonic within a period) */
-	u64	cl_vtadj;	/* intra-period cumulative vt
+	u64	cl_vtadj;		/* intra-period cumulative vt
 					   adjustment */
-	u64	cl_vtoff;	/* inter-period cumulative vt offset */
-	u64	cl_cvtmax;	/* max child's vt in the last period */
+	u64	cl_vtoff;		/* inter-period cumulative vt offset */
+	u64	cl_cvtmax;		/* max child's vt in the last period */
 
 	struct internal_sc cl_rsc;	/* internal real-time service curve */
 	struct internal_sc cl_fsc;	/* internal fair service curve */
@@ -179,8 +179,7 @@
 
 struct hfsc_sched
 {
-	u16	defcls;			/* default class id */
-
+	u16	defcls;				/* default class id */
 	struct hfsc_class root;			/* root class */
 	struct hfsc_class *last_xmit;		/* class that transmitted last
 						   packet (for requeueing) */
@@ -566,8 +565,7 @@
  * service curve starting at (x, y).
  */
 static void
-rtsc_init(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x,
-                                                            u64 y)
+rtsc_init(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x, u64 y)
 {
 	rtsc->x	   = x;
 	rtsc->y    = y;
@@ -626,8 +624,7 @@
  * runtime service curve and the service curve starting at (x, y).
  */
 static void
-rtsc_min(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x,
-                                                           u64 y)
+rtsc_min(struct runtime_sc *rtsc, struct internal_sc *isc, u64 x, u64 y)
 {
 	u64 y1, y2, dx, dy;
 	u32 dsm;

--------------070304050700070807040206--

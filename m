From: Doug Maxey <dwm@austin.ibm.com>
Subject: [PATCH 4/5] ehea: fix phyp checkpatch complaints
Date: Thu, 31 Jan 2008 20:20:50 -0600
Message-ID: <1201832451-23634-5-git-send-email-dwm@austin.ibm.com>
References: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux PowerPC List <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>, Jan-Bernd Themann <themann@de.ibm.com>
To: Jeff Garzik <jgarzik@garzik.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Cc: Jan-Bernd Themann <themann@de.ibm.com>
Signed-off-by: Doug Maxey <dwm@austin.ibm.com>
---
 drivers/net/ehea/ehea_phyp.c |  158 +++++++++++++++++++++---------------------
 drivers/net/ehea/ehea_phyp.h |   22 +++---
 2 files changed, 90 insertions(+), 90 deletions(-)

diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
index 95c4a7f..156eb63 100644
--- a/drivers/net/ehea/ehea_phyp.c
+++ b/drivers/net/ehea/ehea_phyp.c
@@ -6,9 +6,9 @@
  *  (C) Copyright IBM Corp. 2006
  *
  *  Authors:
- *       Christoph Raisch <raisch@de.ibm.com>
- *       Jan-Bernd Themann <themann@de.ibm.com>
- *       Thomas Klein <tklein@de.ibm.com>
+ *	 Christoph Raisch <raisch@de.ibm.com>
+ *	 Jan-Bernd Themann <themann@de.ibm.com>
+ *	 Thomas Klein <tklein@de.ibm.com>
  *
  *
  * This program is free software; you can redistribute it and/or modify
@@ -38,11 +38,11 @@ static inline u16 get_order_of_qentries(u16 queue_entries)
 }
 
 /* Defines for H_CALL H_ALLOC_RESOURCE */
-#define H_ALL_RES_TYPE_QP        1
-#define H_ALL_RES_TYPE_CQ        2
-#define H_ALL_RES_TYPE_EQ        3
-#define H_ALL_RES_TYPE_MR        5
-#define H_ALL_RES_TYPE_MW        6
+#define H_ALL_RES_TYPE_QP	 1
+#define H_ALL_RES_TYPE_CQ	 2
+#define H_ALL_RES_TYPE_EQ	 3
+#define H_ALL_RES_TYPE_MR	 5
+#define H_ALL_RES_TYPE_MW	 6
 
 static long ehea_plpar_hcall_norets(unsigned long opcode,
 				    unsigned long arg1,
@@ -137,77 +137,77 @@ u64 ehea_h_query_ehea_qp(const u64 adapter_handle, const u8 qp_category,
 			 const u64 qp_handle, const u64 sel_mask, void *cb_addr)
 {
 	return ehea_plpar_hcall_norets(H_QUERY_HEA_QP,
-				       adapter_handle,	        /* R4 */
-				       qp_category,	        /* R5 */
-				       qp_handle,               /* R6 */
-				       sel_mask,                /* R7 */
+				       adapter_handle,		/* R4 */
+				       qp_category,		/* R5 */
+				       qp_handle,		/* R6 */
+				       sel_mask,		/* R7 */
 				       virt_to_abs(cb_addr),	/* R8 */
 				       0, 0);
 }
 
 /* input param R5 */
-#define H_ALL_RES_QP_EQPO         EHEA_BMASK_IBM(9, 11)
-#define H_ALL_RES_QP_QPP          EHEA_BMASK_IBM(12, 12)
-#define H_ALL_RES_QP_RQR          EHEA_BMASK_IBM(13, 15)
-#define H_ALL_RES_QP_EQEG         EHEA_BMASK_IBM(16, 16)
-#define H_ALL_RES_QP_LL_QP        EHEA_BMASK_IBM(17, 17)
-#define H_ALL_RES_QP_DMA128       EHEA_BMASK_IBM(19, 19)
-#define H_ALL_RES_QP_HSM          EHEA_BMASK_IBM(20, 21)
-#define H_ALL_RES_QP_SIGT         EHEA_BMASK_IBM(22, 23)
-#define H_ALL_RES_QP_TENURE       EHEA_BMASK_IBM(48, 55)
-#define H_ALL_RES_QP_RES_TYP      EHEA_BMASK_IBM(56, 63)
+#define H_ALL_RES_QP_EQPO	  EHEA_BMASK_IBM(9, 11)
+#define H_ALL_RES_QP_QPP	  EHEA_BMASK_IBM(12, 12)
+#define H_ALL_RES_QP_RQR	  EHEA_BMASK_IBM(13, 15)
+#define H_ALL_RES_QP_EQEG	  EHEA_BMASK_IBM(16, 16)
+#define H_ALL_RES_QP_LL_QP	  EHEA_BMASK_IBM(17, 17)
+#define H_ALL_RES_QP_DMA128	  EHEA_BMASK_IBM(19, 19)
+#define H_ALL_RES_QP_HSM	  EHEA_BMASK_IBM(20, 21)
+#define H_ALL_RES_QP_SIGT	  EHEA_BMASK_IBM(22, 23)
+#define H_ALL_RES_QP_TENURE	  EHEA_BMASK_IBM(48, 55)
+#define H_ALL_RES_QP_RES_TYP	  EHEA_BMASK_IBM(56, 63)
 
 /* input param R9  */
-#define H_ALL_RES_QP_TOKEN        EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_PD           EHEA_BMASK_IBM(32,63)
+#define H_ALL_RES_QP_TOKEN	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_PD		  EHEA_BMASK_IBM(32, 63)
 
 /* input param R10 */
-#define H_ALL_RES_QP_MAX_SWQE     EHEA_BMASK_IBM(4, 7)
-#define H_ALL_RES_QP_MAX_R1WQE    EHEA_BMASK_IBM(12, 15)
-#define H_ALL_RES_QP_MAX_R2WQE    EHEA_BMASK_IBM(20, 23)
-#define H_ALL_RES_QP_MAX_R3WQE    EHEA_BMASK_IBM(28, 31)
+#define H_ALL_RES_QP_MAX_SWQE	  EHEA_BMASK_IBM(4, 7)
+#define H_ALL_RES_QP_MAX_R1WQE	  EHEA_BMASK_IBM(12, 15)
+#define H_ALL_RES_QP_MAX_R2WQE	  EHEA_BMASK_IBM(20, 23)
+#define H_ALL_RES_QP_MAX_R3WQE	  EHEA_BMASK_IBM(28, 31)
 /* Max Send Scatter Gather Elements */
-#define H_ALL_RES_QP_MAX_SSGE     EHEA_BMASK_IBM(37, 39)
-#define H_ALL_RES_QP_MAX_R1SGE    EHEA_BMASK_IBM(45, 47)
+#define H_ALL_RES_QP_MAX_SSGE	  EHEA_BMASK_IBM(37, 39)
+#define H_ALL_RES_QP_MAX_R1SGE	  EHEA_BMASK_IBM(45, 47)
 /* Max Receive SG Elements RQ1 */
-#define H_ALL_RES_QP_MAX_R2SGE    EHEA_BMASK_IBM(53, 55)
-#define H_ALL_RES_QP_MAX_R3SGE    EHEA_BMASK_IBM(61, 63)
+#define H_ALL_RES_QP_MAX_R2SGE	  EHEA_BMASK_IBM(53, 55)
+#define H_ALL_RES_QP_MAX_R3SGE	  EHEA_BMASK_IBM(61, 63)
 
 /* input param R11 */
-#define H_ALL_RES_QP_SWQE_IDL     EHEA_BMASK_IBM(0, 7)
+#define H_ALL_RES_QP_SWQE_IDL	  EHEA_BMASK_IBM(0, 7)
 /* max swqe immediate data length */
-#define H_ALL_RES_QP_PORT_NUM     EHEA_BMASK_IBM(48, 63)
+#define H_ALL_RES_QP_PORT_NUM	  EHEA_BMASK_IBM(48, 63)
 
 /* input param R12 */
-#define H_ALL_RES_QP_TH_RQ2       EHEA_BMASK_IBM(0, 15)
+#define H_ALL_RES_QP_TH_RQ2	  EHEA_BMASK_IBM(0, 15)
 /* Threshold RQ2 */
-#define H_ALL_RES_QP_TH_RQ3       EHEA_BMASK_IBM(16, 31)
+#define H_ALL_RES_QP_TH_RQ3	  EHEA_BMASK_IBM(16, 31)
 /* Threshold RQ3 */
 
 /* output param R6 */
-#define H_ALL_RES_QP_ACT_SWQE     EHEA_BMASK_IBM(0, 15)
-#define H_ALL_RES_QP_ACT_R1WQE    EHEA_BMASK_IBM(16, 31)
-#define H_ALL_RES_QP_ACT_R2WQE    EHEA_BMASK_IBM(32, 47)
-#define H_ALL_RES_QP_ACT_R3WQE    EHEA_BMASK_IBM(48, 63)
+#define H_ALL_RES_QP_ACT_SWQE	  EHEA_BMASK_IBM(0, 15)
+#define H_ALL_RES_QP_ACT_R1WQE	  EHEA_BMASK_IBM(16, 31)
+#define H_ALL_RES_QP_ACT_R2WQE	  EHEA_BMASK_IBM(32, 47)
+#define H_ALL_RES_QP_ACT_R3WQE	  EHEA_BMASK_IBM(48, 63)
 
 /* output param, R7 */
-#define H_ALL_RES_QP_ACT_SSGE     EHEA_BMASK_IBM(0, 7)
-#define H_ALL_RES_QP_ACT_R1SGE    EHEA_BMASK_IBM(8, 15)
-#define H_ALL_RES_QP_ACT_R2SGE    EHEA_BMASK_IBM(16, 23)
-#define H_ALL_RES_QP_ACT_R3SGE    EHEA_BMASK_IBM(24, 31)
+#define H_ALL_RES_QP_ACT_SSGE	  EHEA_BMASK_IBM(0, 7)
+#define H_ALL_RES_QP_ACT_R1SGE	  EHEA_BMASK_IBM(8, 15)
+#define H_ALL_RES_QP_ACT_R2SGE	  EHEA_BMASK_IBM(16, 23)
+#define H_ALL_RES_QP_ACT_R3SGE	  EHEA_BMASK_IBM(24, 31)
 #define H_ALL_RES_QP_ACT_SWQE_IDL EHEA_BMASK_IBM(32, 39)
 
 /* output param R8,R9 */
-#define H_ALL_RES_QP_SIZE_SQ      EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_SIZE_RQ1     EHEA_BMASK_IBM(32, 63)
-#define H_ALL_RES_QP_SIZE_RQ2     EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_SIZE_RQ3     EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_QP_SIZE_SQ	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_SIZE_RQ1	  EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_QP_SIZE_RQ2	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_SIZE_RQ3	  EHEA_BMASK_IBM(32, 63)
 
 /* output param R11,R12 */
-#define H_ALL_RES_QP_LIOBN_SQ     EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_LIOBN_RQ1    EHEA_BMASK_IBM(32, 63)
-#define H_ALL_RES_QP_LIOBN_RQ2    EHEA_BMASK_IBM(0, 31)
-#define H_ALL_RES_QP_LIOBN_RQ3    EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_QP_LIOBN_SQ	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_LIOBN_RQ1	  EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_QP_LIOBN_RQ2	  EHEA_BMASK_IBM(0, 31)
+#define H_ALL_RES_QP_LIOBN_RQ3	  EHEA_BMASK_IBM(32, 63)
 
 u64 ehea_h_alloc_resource_qp(const u64 adapter_handle,
 			     struct ehea_qp_init_attr *init_attr, const u32 pd,
@@ -334,28 +334,28 @@ u64 ehea_h_alloc_resource_cq(const u64 adapter_handle,
 }
 
 /* Defines for H_CALL H_ALLOC_RESOURCE */
-#define H_ALL_RES_TYPE_QP        1
-#define H_ALL_RES_TYPE_CQ        2
-#define H_ALL_RES_TYPE_EQ        3
-#define H_ALL_RES_TYPE_MR        5
-#define H_ALL_RES_TYPE_MW        6
+#define H_ALL_RES_TYPE_QP	 1
+#define H_ALL_RES_TYPE_CQ	 2
+#define H_ALL_RES_TYPE_EQ	 3
+#define H_ALL_RES_TYPE_MR	 5
+#define H_ALL_RES_TYPE_MW	 6
 
 /*  input param R5 */
-#define H_ALL_RES_EQ_NEQ             EHEA_BMASK_IBM(0, 0)
+#define H_ALL_RES_EQ_NEQ	     EHEA_BMASK_IBM(0, 0)
 #define H_ALL_RES_EQ_NON_NEQ_ISN     EHEA_BMASK_IBM(6, 7)
 #define H_ALL_RES_EQ_INH_EQE_GEN     EHEA_BMASK_IBM(16, 16)
-#define H_ALL_RES_EQ_RES_TYPE        EHEA_BMASK_IBM(56, 63)
+#define H_ALL_RES_EQ_RES_TYPE	     EHEA_BMASK_IBM(56, 63)
 /*  input param R6 */
-#define H_ALL_RES_EQ_MAX_EQE         EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_EQ_MAX_EQE	     EHEA_BMASK_IBM(32, 63)
 
 /*  output param R6 */
-#define H_ALL_RES_EQ_LIOBN           EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_EQ_LIOBN	     EHEA_BMASK_IBM(32, 63)
 
 /*  output param R7 */
-#define H_ALL_RES_EQ_ACT_EQE         EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_EQ_ACT_EQE	     EHEA_BMASK_IBM(32, 63)
 
 /*  output param R8 */
-#define H_ALL_RES_EQ_ACT_PS          EHEA_BMASK_IBM(32, 63)
+#define H_ALL_RES_EQ_ACT_PS	     EHEA_BMASK_IBM(32, 63)
 
 /*  output param R9 */
 #define H_ALL_RES_EQ_ACT_EQ_IST_C    EHEA_BMASK_IBM(30, 31)
@@ -453,12 +453,12 @@ u64 ehea_h_register_smr(const u64 adapter_handle, const u64 orig_mr_handle,
 
 	hret = ehea_plpar_hcall9(H_REGISTER_SMR,
 				 outs,
-				 adapter_handle       ,        	 /* R4 */
-				 orig_mr_handle,                 /* R5 */
-				 vaddr_in,                       /* R6 */
-				 (((u64)access_ctrl) << 32ULL),  /* R7 */
-				 pd,                             /* R8 */
-				 0, 0, 0, 0);	   		 /* R9-R12 */
+				 adapter_handle	      ,		 /* R4 */
+				 orig_mr_handle,		 /* R5 */
+				 vaddr_in,			 /* R6 */
+				 (((u64)access_ctrl) << 32ULL),	 /* R7 */
+				 pd,				 /* R8 */
+				 0, 0, 0, 0);			 /* R9-R12 */
 
 	mr->handle = outs[0];
 	mr->lkey = (u32)outs[2];
@@ -471,11 +471,11 @@ u64 ehea_h_disable_and_get_hea(const u64 adapter_handle, const u64 qp_handle)
 	u64 outs[PLPAR_HCALL9_BUFSIZE];
 
 	return ehea_plpar_hcall9(H_DISABLE_AND_GET_HEA,
-       				 outs,
+				 outs,
 				 adapter_handle,		/* R4 */
 				 H_DISABLE_GET_EHEA_WQE_P,	/* R5 */
 				 qp_handle,			/* R6 */
-				 0, 0, 0, 0, 0, 0);             /* R7-R12 */
+				 0, 0, 0, 0, 0, 0);		/* R7-R12 */
 }
 
 u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle,
@@ -483,9 +483,9 @@ u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle,
 {
 	return ehea_plpar_hcall_norets(H_FREE_RESOURCE,
 				       adapter_handle,	   /* R4 */
-				       res_handle,         /* R5 */
+				       res_handle,	   /* R5 */
 				       force_bit,
-				       0, 0, 0, 0);        /* R7-R10 */
+				       0, 0, 0, 0);	   /* R7-R10 */
 }
 
 u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
@@ -493,13 +493,13 @@ u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
 			     const u32 pd, u64 *mr_handle, u32 *lkey)
 {
 	u64 hret;
- 	u64 outs[PLPAR_HCALL9_BUFSIZE];
+	u64 outs[PLPAR_HCALL9_BUFSIZE];
 
 	hret = ehea_plpar_hcall9(H_ALLOC_HEA_RESOURCE,
 				 outs,
 				 adapter_handle,		   /* R4 */
 				 5,				   /* R5 */
-				 vaddr,			           /* R6 */
+				 vaddr,				   /* R6 */
 				 length,			   /* R7 */
 				 (((u64) access_ctrl) << 32ULL),   /* R8 */
 				 pd,				   /* R9 */
@@ -619,8 +619,8 @@ u64 ehea_h_error_data(const u64 adapter_handle, const u64 ressource_handle,
 		      void *rblock)
 {
 	return ehea_plpar_hcall_norets(H_ERROR_DATA,
-				       adapter_handle,          /* R4 */
-				       ressource_handle,        /* R5 */
-				       virt_to_abs(rblock),     /* R6 */
-				       0, 0, 0, 0);             /* R7-R12 */
+				       adapter_handle,		/* R4 */
+				       ressource_handle,	/* R5 */
+				       virt_to_abs(rblock),	/* R6 */
+				       0, 0, 0, 0);		/* R7-R12 */
 }
diff --git a/drivers/net/ehea/ehea_phyp.h b/drivers/net/ehea/ehea_phyp.h
index faa191d..f3628c8 100644
--- a/drivers/net/ehea/ehea_phyp.h
+++ b/drivers/net/ehea/ehea_phyp.h
@@ -93,7 +93,7 @@ static inline void hcp_epas_ctor(struct h_epas *epas, u64 paddr_kernel,
 static inline void hcp_epas_dtor(struct h_epas *epas)
 {
 	if (epas->kernel.addr)
-		iounmap((void __iomem*)((u64)epas->kernel.addr & PAGE_MASK));
+		iounmap((void __iomem *)((u64)epas->kernel.addr & PAGE_MASK));
 
 	epas->user.addr = 0;
 	epas->kernel.addr = 0;
@@ -388,23 +388,23 @@ u64 ehea_h_modify_ehea_qp(const u64 adapter_handle,
 			  const u64 qp_handle,
 			  const u64 sel_mask,
 			  void *cb_addr,
-			  u64 * inv_attr_id,
-			  u64 * proc_mask, u16 * out_swr, u16 * out_rwr);
+			  u64 *inv_attr_id,
+			  u64 *proc_mask, u16 *out_swr, u16 *out_rwr);
 
 u64 ehea_h_alloc_resource_eq(const u64 adapter_handle,
-			     struct ehea_eq_attr *eq_attr, u64 * eq_handle);
+			     struct ehea_eq_attr *eq_attr, u64 *eq_handle);
 
 u64 ehea_h_alloc_resource_cq(const u64 adapter_handle,
 			     struct ehea_cq_attr *cq_attr,
-			     u64 * cq_handle, struct h_epas *epas);
+			     u64 *cq_handle, struct h_epas *epas);
 
 u64 ehea_h_alloc_resource_qp(const u64 adapter_handle,
 			     struct ehea_qp_init_attr *init_attr,
 			     const u32 pd,
-			     u64 * qp_handle, struct h_epas *h_epas);
+			     u64 *qp_handle, struct h_epas *h_epas);
 
-#define H_REG_RPAGE_PAGE_SIZE          EHEA_BMASK_IBM(48,55)
-#define H_REG_RPAGE_QT                 EHEA_BMASK_IBM(62,63)
+#define H_REG_RPAGE_PAGE_SIZE          EHEA_BMASK_IBM(48, 55)
+#define H_REG_RPAGE_QT                 EHEA_BMASK_IBM(62, 63)
 
 u64 ehea_h_register_rpage(const u64 adapter_handle,
 			  const u8 pagesize,
@@ -426,7 +426,7 @@ u64 ehea_h_free_resource(const u64 adapter_handle, const u64 res_handle,
 
 u64 ehea_h_alloc_resource_mr(const u64 adapter_handle, const u64 vaddr,
 			     const u64 length, const u32 access_ctrl,
-			     const u32 pd, u64 * mr_handle, u32 * lkey);
+			     const u32 pd, u64 *mr_handle, u32 *lkey);
 
 u64 ehea_h_register_rpage_mr(const u64 adapter_handle, const u64 mr_handle,
 			     const u8 pagesize, const u8 queue_type,
@@ -439,8 +439,8 @@ u64 ehea_h_register_smr(const u64 adapter_handle, const u64 orig_mr_handle,
 u64 ehea_h_query_ehea(const u64 adapter_handle, void *cb_addr);
 
 /* output param R5 */
-#define H_MEHEAPORT_CAT		EHEA_BMASK_IBM(40,47)
-#define H_MEHEAPORT_PN		EHEA_BMASK_IBM(48,63)
+#define H_MEHEAPORT_CAT		EHEA_BMASK_IBM(40, 47)
+#define H_MEHEAPORT_PN		EHEA_BMASK_IBM(48, 63)
 
 u64 ehea_h_query_ehea_port(const u64 adapter_handle, const u16 port_num,
 			   const u8 cb_cat, const u64 select_mask,
-- 
1.5.3.8

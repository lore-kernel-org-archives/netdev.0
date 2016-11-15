From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 11/11] IB/hns: Fix for Checkpatch.pl comment style errors
Date: Tue, 15 Nov 2016 18:10:53 +0000
Message-ID: <20161115181053.399568-12-salil.mehta@huawei.com>
References: <20161115181053.399568-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115181053.399568-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch correct the comment style errors caught by
checkpatch.pl script

Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
---
 drivers/infiniband/hw/hns/hns_roce_cmd.c    |    8 ++--
 drivers/infiniband/hw/hns/hns_roce_device.h |   28 ++++++-------
 drivers/infiniband/hw/hns/hns_roce_eq.c     |    6 +--
 drivers/infiniband/hw/hns/hns_roce_hem.c    |    6 +--
 drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |   58 +++++++++++++--------------
 drivers/infiniband/hw/hns/hns_roce_main.c   |   28 ++++++-------
 6 files changed, 67 insertions(+), 67 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_cmd.c b/drivers/infiniband/hw/hns/hns_roce_cmd.c
index 2a0b6c0..8c1f7a6 100644
--- a/drivers/infiniband/hw/hns/hns_roce_cmd.c
+++ b/drivers/infiniband/hw/hns/hns_roce_cmd.c
@@ -216,10 +216,10 @@ static int __hns_roce_cmd_mbox_wait(struct hns_roce_dev *hr_dev, u64 in_param,
 		goto out;
 
 	/*
-	* It is timeout when wait_for_completion_timeout return 0
-	* The return value is the time limit set in advance
-	* how many seconds showing
-	*/
+	 * It is timeout when wait_for_completion_timeout return 0
+	 * The return value is the time limit set in advance
+	 * how many seconds showing
+	 */
 	if (!wait_for_completion_timeout(&context->done,
 					 msecs_to_jiffies(timeout))) {
 		dev_err(dev, "[cmd]wait_for_completion_timeout timeout\n");
diff --git a/drivers/infiniband/hw/hns/hns_roce_device.h b/drivers/infiniband/hw/hns/hns_roce_device.h
index 9ef1cc3..e48464d 100644
--- a/drivers/infiniband/hw/hns/hns_roce_device.h
+++ b/drivers/infiniband/hw/hns/hns_roce_device.h
@@ -201,9 +201,9 @@ struct hns_roce_bitmap {
 /* Order = 0: bitmap is biggest, order = max bitmap is least (only a bit) */
 /* Every bit repesent to a partner free/used status in bitmap */
 /*
-* Initial, bits of other bitmap are all 0 except that a bit of max_order is 1
-* Bit = 1 represent to idle and available; bit = 0: not available
-*/
+ * Initial, bits of other bitmap are all 0 except that a bit of max_order is 1
+ * Bit = 1 represent to idle and available; bit = 0: not available
+ */
 struct hns_roce_buddy {
 	/* Members point to every order level bitmap */
 	unsigned long **bits;
@@ -365,25 +365,25 @@ struct hns_roce_cmdq {
 	struct mutex		hcr_mutex;
 	struct semaphore	poll_sem;
 	/*
-	* Event mode: cmd register mutex protection,
-	* ensure to not exceed max_cmds and user use limit region
-	*/
+	 * Event mode: cmd register mutex protection,
+	 * ensure to not exceed max_cmds and user use limit region
+	 */
 	struct semaphore	event_sem;
 	int			max_cmds;
 	spinlock_t		context_lock;
 	int			free_head;
 	struct hns_roce_cmd_context *context;
 	/*
-	* Result of get integer part
-	* which max_comds compute according a power of 2
-	*/
+	 * Result of get integer part
+	 * which max_comds compute according a power of 2
+	 */
 	u16			token_mask;
 	/*
-	* Process whether use event mode, init default non-zero
-	* After the event queue of cmd event ready,
-	* can switch into event mode
-	* close device, switch into poll mode(non event mode)
-	*/
+	 * Process whether use event mode, init default non-zero
+	 * After the event queue of cmd event ready,
+	 * can switch into event mode
+	 * close device, switch into poll mode(non event mode)
+	 */
 	u8			use_events;
 	u8			toggle;
 };
diff --git a/drivers/infiniband/hw/hns/hns_roce_eq.c b/drivers/infiniband/hw/hns/hns_roce_eq.c
index 21e21b0..50f8649 100644
--- a/drivers/infiniband/hw/hns/hns_roce_eq.c
+++ b/drivers/infiniband/hw/hns/hns_roce_eq.c
@@ -371,9 +371,9 @@ static int hns_roce_aeq_ovf_int(struct hns_roce_dev *hr_dev,
 	int i = 0;
 
 	/**
-	* AEQ overflow ECC mult bit err CEQ overflow alarm
-	* must clear interrupt, mask irq, clear irq, cancel mask operation
-	*/
+	 * AEQ overflow ECC mult bit err CEQ overflow alarm
+	 * must clear interrupt, mask irq, clear irq, cancel mask operation
+	 */
 	aeshift_val = roce_read(hr_dev, ROCEE_CAEP_AEQC_AEQE_SHIFT_REG);
 
 	if (roce_get_bit(aeshift_val,
diff --git a/drivers/infiniband/hw/hns/hns_roce_hem.c b/drivers/infiniband/hw/hns/hns_roce_hem.c
index 250d8f2..c5104e0 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hem.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hem.c
@@ -80,9 +80,9 @@ struct hns_roce_hem *hns_roce_alloc_hem(struct hns_roce_dev *hr_dev, int npages,
 			--order;
 
 		/*
-		* Alloc memory one time. If failed, don't alloc small block
-		* memory, directly return fail.
-		*/
+		 * Alloc memory one time. If failed, don't alloc small block
+		 * memory, directly return fail.
+		 */
 		mem = &chunk->mem[chunk->npages];
 		buf = dma_alloc_coherent(&hr_dev->pdev->dev, PAGE_SIZE << order,
 				&sg_dma_address(mem), gfp_mask);
diff --git a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
index 34b7898..125ab90 100644
--- a/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
+++ b/drivers/infiniband/hw/hns/hns_roce_hw_v1.c
@@ -1352,9 +1352,9 @@ static void __hns_roce_v1_cq_clean(struct hns_roce_cq *hr_cq, u32 qpn,
 	}
 
 	/*
-	* Now backwards through the CQ, removing CQ entries
-	* that match our QP by overwriting them with next entries.
-	*/
+	 * Now backwards through the CQ, removing CQ entries
+	 * that match our QP by overwriting them with next entries.
+	 */
 	while ((int) --prod_index - (int) hr_cq->cons_index >= 0) {
 		cqe = get_cqe(hr_cq, prod_index & hr_cq->ib_cq.cqe);
 		if ((roce_get_field(cqe->cqe_byte_16, CQE_BYTE_16_LOCAL_QPN_M,
@@ -1376,9 +1376,9 @@ static void __hns_roce_v1_cq_clean(struct hns_roce_cq *hr_cq, u32 qpn,
 	if (nfreed) {
 		hr_cq->cons_index += nfreed;
 		/*
-		* Make sure update of buffer contents is done before
-		* updating consumer index.
-		*/
+		 * Make sure update of buffer contents is done before
+		 * updating consumer index.
+		 */
 		wmb();
 
 		hns_roce_v1_cq_set_ci(hr_cq, hr_cq->cons_index);
@@ -1473,7 +1473,7 @@ void hns_roce_v1_write_cqc(struct hns_roce_dev *hr_dev,
 	roce_set_bit(cq_context->cqc_byte_32,
 		     CQ_CQNTEXT_CQC_BYTE_32_TYPE_OF_COMPLETION_NOTIFICATION_S,
 		     0);
-	/*The initial value of cq's ci is 0 */
+	/* The initial value of cq's ci is 0 */
 	roce_set_field(cq_context->cqc_byte_32,
 		       CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_M,
 		       CQ_CONTEXT_CQC_BYTE_32_CQ_CONS_IDX_S, 0);
@@ -1490,9 +1490,9 @@ int hns_roce_v1_req_notify_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags)
 	notification_flag = (flags & IB_CQ_SOLICITED_MASK) ==
 			    IB_CQ_SOLICITED ? CQ_DB_REQ_NOT : CQ_DB_REQ_NOT_SOL;
 	/*
-	* flags = 0; Notification Flag = 1, next
-	* flags = 1; Notification Flag = 0, solocited
-	*/
+	 * flags = 0; Notification Flag = 1, next
+	 * flags = 1; Notification Flag = 0, solocited
+	 */
 	doorbell[0] = hr_cq->cons_index & ((hr_cq->cq_depth << 1) - 1);
 	roce_set_bit(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_HW_SYNS_S, 1);
 	roce_set_field(doorbell[1], ROCEE_DB_OTHERS_H_ROCEE_DB_OTH_CMD_M,
@@ -1647,10 +1647,10 @@ static int hns_roce_v1_poll_one(struct hns_roce_cq *hr_cq,
 		wq = &(*cur_qp)->sq;
 		if ((*cur_qp)->sq_signal_bits) {
 			/*
-			* If sg_signal_bit is 1,
-			* firstly tail pointer updated to wqe
-			* which current cqe correspond to
-			*/
+			 * If sg_signal_bit is 1,
+			 * firstly tail pointer updated to wqe
+			 * which current cqe correspond to
+			 */
 			wqe_ctr = (u16)roce_get_field(cqe->cqe_byte_4,
 						      CQE_BYTE_4_WQE_INDEX_M,
 						      CQE_BYTE_4_WQE_INDEX_S);
@@ -2072,11 +2072,11 @@ static int hns_roce_v1_m_qp(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
 	}
 
 	/*
-	*Reset to init
-	*	Mandatory param:
-	*	IB_QP_STATE | IB_QP_PKEY_INDEX | IB_QP_PORT | IB_QP_ACCESS_FLAGS
-	*	Optional param: NA
-	*/
+	 * Reset to init
+	 *	Mandatory param:
+	 *	IB_QP_STATE | IB_QP_PKEY_INDEX | IB_QP_PORT | IB_QP_ACCESS_FLAGS
+	 *	Optional param: NA
+	 */
 	if (cur_state == IB_QPS_RESET && new_state == IB_QPS_INIT) {
 		roce_set_field(context->qpc_bytes_4,
 			       QP_CONTEXT_QPC_BYTES_4_TRANSPORT_SERVICE_TYPE_M,
@@ -2584,9 +2584,9 @@ static int hns_roce_v1_m_qp(struct ib_qp *ibqp, const struct ib_qp_attr *attr,
 	}
 
 	/*
-	* Use rst2init to instead of init2init with drv,
-	* need to hw to flash RQ HEAD by DB again
-	*/
+	 * Use rst2init to instead of init2init with drv,
+	 * need to hw to flash RQ HEAD by DB again
+	 */
 	if (cur_state == IB_QPS_INIT && new_state == IB_QPS_INIT) {
 		/* Memory barrier */
 		wmb();
@@ -2708,7 +2708,7 @@ static int hns_roce_v1_q_sqp(struct ib_qp *ibqp, struct ib_qp_attr *qp_attr,
 		goto done;
 	}
 
-	addr = ROCEE_QP1C_CFG0_0_REG + 
+	addr = ROCEE_QP1C_CFG0_0_REG +
 		hr_qp->port * sizeof(struct hns_roce_sqp_context);
 	context.qp1c_bytes_4 = roce_read(hr_dev, addr);
 	context.sq_rq_bt_l = roce_read(hr_dev, addr + 1);
@@ -2921,9 +2921,9 @@ static void hns_roce_v1_destroy_qp_common(struct hns_roce_dev *hr_dev,
 	if (hr_qp->ibqp.qp_type == IB_QPT_RC) {
 		if (hr_qp->state != IB_QPS_RESET) {
 			/*
-			* Set qp to ERR,
-			* waiting for hw complete processing all dbs
-			*/
+			 * Set qp to ERR,
+			 * waiting for hw complete processing all dbs
+			 */
 			if (hns_roce_v1_qp_modify(hr_dev, NULL,
 					to_hns_roce_state(
 						(enum ib_qp_state)hr_qp->state),
@@ -2936,9 +2936,9 @@ static void hns_roce_v1_destroy_qp_common(struct hns_roce_dev *hr_dev,
 			sdbisusepr_val = roce_read(hr_dev,
 					 ROCEE_SDB_ISSUE_PTR_REG);
 			/*
-			* Query db process status,
-			* until hw process completely
-			*/
+			 * Query db process status,
+			 * until hw process completely
+			 */
 			end = msecs_to_jiffies(
 			      HNS_ROCE_QP_DESTROY_TIMEOUT_MSECS) + jiffies;
 			do {
diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniband/hw/hns/hns_roce_main.c
index 795ef97..914d0ac 100644
--- a/drivers/infiniband/hw/hns/hns_roce_main.c
+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
@@ -148,8 +148,8 @@ static int handle_en_event(struct hns_roce_dev *hr_dev, u8 port,
 		break;
 	case NETDEV_DOWN:
 		/*
-		* In v1 engine, only support all ports closed together.
-		*/
+		 * In v1 engine, only support all ports closed together.
+		 */
 		break;
 	default:
 		dev_dbg(dev, "NETDEV event = 0x%x!\n", (u32)(event));
@@ -773,10 +773,10 @@ static int hns_roce_init_hem(struct hns_roce_dev *hr_dev)
 }
 
 /**
-* hns_roce_setup_hca - setup host channel adapter
-* @hr_dev: pointer to hns roce device
-* Return : int
-*/
+ * hns_roce_setup_hca - setup host channel adapter
+ * @hr_dev: pointer to hns roce device
+ * Return : int
+ */
 static int hns_roce_setup_hca(struct hns_roce_dev *hr_dev)
 {
 	int ret;
@@ -841,11 +841,11 @@ static int hns_roce_setup_hca(struct hns_roce_dev *hr_dev)
 }
 
 /**
-* hns_roce_probe - RoCE driver entrance
-* @pdev: pointer to platform device
-* Return : int
-*
-*/
+ * hns_roce_probe - RoCE driver entrance
+ * @pdev: pointer to platform device
+ * Return : int
+ *
+ */
 static int hns_roce_probe(struct platform_device *pdev)
 {
 	int ret;
@@ -958,9 +958,9 @@ static int hns_roce_probe(struct platform_device *pdev)
 }
 
 /**
-* hns_roce_remove - remove RoCE device
-* @pdev: pointer to platform device
-*/
+ * hns_roce_remove - remove RoCE device
+ * @pdev: pointer to platform device
+ */
 static int hns_roce_remove(struct platform_device *pdev)
 {
 	struct hns_roce_dev *hr_dev = platform_get_drvdata(pdev);
-- 
1.7.9.5

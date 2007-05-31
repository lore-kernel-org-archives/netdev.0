From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 1/2] ehea: Whitespace cleanup
Date: Thu, 31 May 2007 13:54:09 +0200
Message-ID: <200705311354.09992.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:6630 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757442AbXEaLyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 07:54:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes several whitespace issues.

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


diff -Nurp -X dontdiff linux-2.6.22-rc3/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.22-rc3/drivers/net/ehea/ehea.h	2007-05-30 12:13:36.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2007-05-30 12:27:13.000000000 +0200
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0061"
+#define DRV_VERSION	"EHEA_0062"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -136,10 +136,10 @@ void ehea_dump(void *adr, int len, char 
 	(0xffffffffffffffffULL >> ((64 - (mask)) & 0xffff))
 
 #define EHEA_BMASK_SET(mask, value) \
-        ((EHEA_BMASK_MASK(mask) & ((u64)(value))) << EHEA_BMASK_SHIFTPOS(mask))
+	((EHEA_BMASK_MASK(mask) & ((u64)(value))) << EHEA_BMASK_SHIFTPOS(mask))
 
 #define EHEA_BMASK_GET(mask, value) \
-        (EHEA_BMASK_MASK(mask) & (((u64)(value)) >> EHEA_BMASK_SHIFTPOS(mask)))
+	(EHEA_BMASK_MASK(mask) & (((u64)(value)) >> EHEA_BMASK_SHIFTPOS(mask)))
 
 /*
  * Generic ehea page
@@ -190,7 +190,7 @@ struct ehea_av;
  * Queue attributes passed to ehea_create_qp()
  */
 struct ehea_qp_init_attr {
-        /* input parameter */
+	/* input parameter */
 	u32 qp_token;           /* queue token */
 	u8 low_lat_rq1;
 	u8 signalingtype;       /* cqe generation flag */
@@ -212,7 +212,7 @@ struct ehea_qp_init_attr {
 	u64 recv_cq_handle;
 	u64 aff_eq_handle;
 
-        /* output parameter */
+	/* output parameter */
 	u32 qp_nr;
 	u16 act_nr_send_wqes;
 	u16 act_nr_rwqes_rq1;
@@ -279,12 +279,12 @@ struct ehea_qp {
  * Completion Queue attributes
  */
 struct ehea_cq_attr {
-        /* input parameter */
+	/* input parameter */
 	u32 max_nr_of_cqes;
 	u32 cq_token;
 	u64 eq_handle;
 
-        /* output parameter */
+	/* output parameter */
 	u32 act_nr_of_cqes;
 	u32 nr_pages;
 };
diff -Nurp -X dontdiff linux-2.6.22-rc3/drivers/net/ehea/ehea_hw.h patched_kernel/drivers/net/ehea/ehea_hw.h
--- linux-2.6.22-rc3/drivers/net/ehea/ehea_hw.h	2007-05-26 04:55:14.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_hw.h	2007-05-30 12:27:13.000000000 +0200
@@ -211,34 +211,34 @@ static inline void epa_store_acc(struct 
 }
 
 #define epa_store_eq(epa, offset, value)\
-        epa_store(epa, EQTEMM_OFFSET(offset), value)
+	epa_store(epa, EQTEMM_OFFSET(offset), value)
 #define epa_load_eq(epa, offset)\
-        epa_load(epa, EQTEMM_OFFSET(offset))
+	epa_load(epa, EQTEMM_OFFSET(offset))
 
 #define epa_store_cq(epa, offset, value)\
-        epa_store(epa, CQTEMM_OFFSET(offset), value)
+	epa_store(epa, CQTEMM_OFFSET(offset), value)
 #define epa_load_cq(epa, offset)\
-        epa_load(epa, CQTEMM_OFFSET(offset))
+	epa_load(epa, CQTEMM_OFFSET(offset))
 
 #define epa_store_qp(epa, offset, value)\
-        epa_store(epa, QPTEMM_OFFSET(offset), value)
+	epa_store(epa, QPTEMM_OFFSET(offset), value)
 #define epa_load_qp(epa, offset)\
-        epa_load(epa, QPTEMM_OFFSET(offset))
+	epa_load(epa, QPTEMM_OFFSET(offset))
 
 #define epa_store_qped(epa, offset, value)\
-        epa_store(epa, QPEDMM_OFFSET(offset), value)
+	epa_store(epa, QPEDMM_OFFSET(offset), value)
 #define epa_load_qped(epa, offset)\
-        epa_load(epa, QPEDMM_OFFSET(offset))
+	epa_load(epa, QPEDMM_OFFSET(offset))
 
 #define epa_store_mrmw(epa, offset, value)\
-        epa_store(epa, MRMWMM_OFFSET(offset), value)
+	epa_store(epa, MRMWMM_OFFSET(offset), value)
 #define epa_load_mrmw(epa, offset)\
-        epa_load(epa, MRMWMM_OFFSET(offset))
+	epa_load(epa, MRMWMM_OFFSET(offset))
 
 #define epa_store_base(epa, offset, value)\
-        epa_store(epa, HCAGR_OFFSET(offset), value)
+	epa_store(epa, HCAGR_OFFSET(offset), value)
 #define epa_load_base(epa, offset)\
-        epa_load(epa, HCAGR_OFFSET(offset))
+	epa_load(epa, HCAGR_OFFSET(offset))
 
 static inline void ehea_update_sqa(struct ehea_qp *qp, u16 nr_wqes)
 {
diff -Nurp -X dontdiff linux-2.6.22-rc3/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.22-rc3/drivers/net/ehea/ehea_main.c	2007-05-30 12:13:36.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-05-30 12:27:13.000000000 +0200
@@ -81,7 +81,7 @@ MODULE_PARM_DESC(use_mcs, " 0:NAPI, 1:Mu
 static int port_name_cnt = 0;
 
 static int __devinit ehea_probe_adapter(struct ibmebus_dev *dev,
-                                        const struct of_device_id *id);
+					const struct of_device_id *id);
 
 static int __devexit ehea_remove(struct ibmebus_dev *dev);
 
@@ -236,7 +236,7 @@ static int ehea_refill_rq_def(struct ehe
 
 		rwqe = ehea_get_next_rwqe(qp, rq_nr);
 		rwqe->wr_id = EHEA_BMASK_SET(EHEA_WR_ID_TYPE, wqe_type)
-		            | EHEA_BMASK_SET(EHEA_WR_ID_INDEX, index);
+			    | EHEA_BMASK_SET(EHEA_WR_ID_INDEX, index);
 		rwqe->sg_list[0].l_key = pr->recv_mr.lkey;
 		rwqe->sg_list[0].vaddr = (u64)skb->data;
 		rwqe->sg_list[0].len = packet_size;
@@ -427,7 +427,7 @@ static struct ehea_cqe *ehea_proc_rwqes(
 						break;
 				}
 				skb_copy_to_linear_data(skb, ((char*)cqe) + 64,
-					       cqe->num_bytes_transfered - 4);
+						 cqe->num_bytes_transfered - 4);
 				ehea_fill_skb(port->netdev, skb, cqe);
 			} else if (rq == 2) {  /* RQ2 */
 				skb = get_skb_by_index(skb_arr_rq2,
@@ -617,7 +617,7 @@ static struct ehea_port *ehea_get_port(s
 
 	for (i = 0; i < EHEA_MAX_PORTS; i++)
 		if (adapter->port[i])
-	                if (adapter->port[i]->logical_port_id == logical_port)
+			if (adapter->port[i]->logical_port_id == logical_port)
 				return adapter->port[i];
 	return NULL;
 }
@@ -1694,6 +1694,7 @@ static void ehea_xmit2(struct sk_buff *s
 {
 	if (skb->protocol == htons(ETH_P_IP)) {
 		const struct iphdr *iph = ip_hdr(skb);
+
 		/* IPv4 */
 		swqe->tx_control |= EHEA_SWQE_CRC
 				 | EHEA_SWQE_IP_CHECKSUM
@@ -1704,13 +1705,12 @@ static void ehea_xmit2(struct sk_buff *s
 		write_ip_start_end(swqe, skb);
 
 		if (iph->protocol == IPPROTO_UDP) {
-			if ((iph->frag_off & IP_MF) ||
-			    (iph->frag_off & IP_OFFSET))
+			if ((iph->frag_off & IP_MF)
+			    || (iph->frag_off & IP_OFFSET))
 				/* IP fragment, so don't change cs */
 				swqe->tx_control &= ~EHEA_SWQE_TCP_CHECKSUM;
 			else
 				write_udp_offset_end(swqe, skb);
-
 		} else if (iph->protocol == IPPROTO_TCP) {
 			write_tcp_offset_end(swqe, skb);
 		}
@@ -1738,6 +1738,7 @@ static void ehea_xmit3(struct sk_buff *s
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		const struct iphdr *iph = ip_hdr(skb);
+
 		/* IPv4 */
 		write_ip_start_end(swqe, skb);
 
@@ -1750,8 +1751,8 @@ static void ehea_xmit3(struct sk_buff *s
 			write_tcp_offset_end(swqe, skb);
 
 		} else if (iph->protocol == IPPROTO_UDP) {
-			if ((iph->frag_off & IP_MF) ||
-			    (iph->frag_off & IP_OFFSET))
+			if ((iph->frag_off & IP_MF)
+			    || (iph->frag_off & IP_OFFSET))
 				/* IP fragment, so don't change cs */
 				swqe->tx_control |= EHEA_SWQE_CRC
 						 | EHEA_SWQE_IMM_DATA_PRESENT;
@@ -2409,7 +2410,7 @@ static void __devinit logical_port_relea
 }
 
 static int ehea_driver_sysfs_add(struct device *dev,
-                                 struct device_driver *driver)
+				 struct device_driver *driver)
 {
 	int ret;
 
@@ -2426,7 +2427,7 @@ static int ehea_driver_sysfs_add(struct 
 }
 
 static void ehea_driver_sysfs_remove(struct device *dev,
-                                     struct device_driver *driver)
+				     struct device_driver *driver)
 {
 	struct device_driver *drv = driver;
 
@@ -2455,7 +2456,7 @@ static struct device *ehea_register_port
 	}
 
 	ret = device_create_file(&port->ofdev.dev, &dev_attr_log_port_id);
-        if (ret) {
+	if (ret) {
 		ehea_error("failed to register attributes, ret=%d", ret);
 		goto out_unreg_of_dev;
 	}
@@ -2603,6 +2604,7 @@ static int ehea_setup_ports(struct ehea_
 {
 	struct device_node *lhea_dn;
 	struct device_node *eth_dn = NULL;
+
 	const u32 *dn_log_port_id;
 	int i = 0;
 
@@ -2610,7 +2612,7 @@ static int ehea_setup_ports(struct ehea_
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
 		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
-						    NULL);
+						 NULL);
 		if (!dn_log_port_id) {
 			ehea_error("bad device node: eth_dn name=%s",
 				   eth_dn->full_name);
@@ -2650,7 +2652,7 @@ static struct device_node *ehea_get_eth_
 	while ((eth_dn = of_get_next_child(lhea_dn, eth_dn))) {
 
 		dn_log_port_id = of_get_property(eth_dn, "ibm,hea-port-no",
-						    NULL);
+						 NULL);
 		if (dn_log_port_id)
 			if (*dn_log_port_id == logical_port_id)
 				return eth_dn;
@@ -2791,7 +2793,7 @@ static int __devinit ehea_probe_adapter(
 	adapter->ebus_dev = dev;
 
 	adapter_handle = of_get_property(dev->ofdev.node, "ibm,hea-handle",
-					    NULL);
+					 NULL);
 	if (adapter_handle)
 		adapter->handle = *adapter_handle;
 
diff -Nurp -X dontdiff linux-2.6.22-rc3/drivers/net/ehea/ehea_qmr.c patched_kernel/drivers/net/ehea/ehea_qmr.c
--- linux-2.6.22-rc3/drivers/net/ehea/ehea_qmr.c	2007-05-26 04:55:14.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_qmr.c	2007-05-30 12:27:13.000000000 +0200
@@ -211,7 +211,7 @@ u64 ehea_destroy_cq_res(struct ehea_cq *
 	u64 hret;
 	u64 adapter_handle = cq->adapter->handle;
 
-        /* deregister all previous registered pages */
+	/* deregister all previous registered pages */
 	hret = ehea_h_free_resource(adapter_handle, cq->fw_handle, force);
 	if (hret != H_SUCCESS)
 		return hret;
@@ -362,7 +362,7 @@ int ehea_destroy_eq(struct ehea_eq *eq)
 	if (hret != H_SUCCESS) {
 		ehea_error("destroy EQ failed");
 		return -EIO;
-        }
+	}
 
 	return 0;
 }
@@ -507,44 +507,44 @@ out_freemem:
 
 u64 ehea_destroy_qp_res(struct ehea_qp *qp, u64 force)
 {
-        u64 hret;
-        struct ehea_qp_init_attr *qp_attr = &qp->init_attr;
+	u64 hret;
+	struct ehea_qp_init_attr *qp_attr = &qp->init_attr;
 
 
-        ehea_h_disable_and_get_hea(qp->adapter->handle, qp->fw_handle);
-        hret = ehea_h_free_resource(qp->adapter->handle, qp->fw_handle, force);
-        if (hret != H_SUCCESS)
-                return hret;
+	ehea_h_disable_and_get_hea(qp->adapter->handle, qp->fw_handle);
+	hret = ehea_h_free_resource(qp->adapter->handle, qp->fw_handle, force);
+	if (hret != H_SUCCESS)
+		return hret;
 
-        hw_queue_dtor(&qp->hw_squeue);
-        hw_queue_dtor(&qp->hw_rqueue1);
+	hw_queue_dtor(&qp->hw_squeue);
+	hw_queue_dtor(&qp->hw_rqueue1);
 
-        if (qp_attr->rq_count > 1)
-                hw_queue_dtor(&qp->hw_rqueue2);
-        if (qp_attr->rq_count > 2)
-                hw_queue_dtor(&qp->hw_rqueue3);
-        kfree(qp);
+	if (qp_attr->rq_count > 1)
+		hw_queue_dtor(&qp->hw_rqueue2);
+	if (qp_attr->rq_count > 2)
+		hw_queue_dtor(&qp->hw_rqueue3);
+	kfree(qp);
 
-        return hret;
+	return hret;
 }
 
 int ehea_destroy_qp(struct ehea_qp *qp)
 {
-        u64 hret;
-        if (!qp)
-                return 0;
-
-        if ((hret = ehea_destroy_qp_res(qp, NORMAL_FREE)) == H_R_STATE) {
-                ehea_error_data(qp->adapter, qp->fw_handle);
-                hret = ehea_destroy_qp_res(qp, FORCE_FREE);
-        }
-
-        if (hret != H_SUCCESS) {
-                ehea_error("destroy QP failed");
-                return -EIO;
-        }
+	u64 hret;
+	if (!qp)
+		return 0;
+
+	if ((hret = ehea_destroy_qp_res(qp, NORMAL_FREE)) == H_R_STATE) {
+		ehea_error_data(qp->adapter, qp->fw_handle);
+		hret = ehea_destroy_qp_res(qp, FORCE_FREE);
+	}
+
+	if (hret != H_SUCCESS) {
+		ehea_error("destroy QP failed");
+		return -EIO;
+	}
 
-        return 0;
+	return 0;
 }
 
 int ehea_reg_kernel_mr(struct ehea_adapter *adapter, struct ehea_mr *mr)


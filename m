From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 5/5] drivers/net/ethernet: Fix non-kernel-doc
 comments with kernel-doc start markers
Date: Fri, 6 Jul 2012 23:48:08 +0100
Message-ID: <1341614888.2923.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341614561.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30787 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756257Ab2GFWsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 18:48:12 -0400
In-Reply-To: <1341614561.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert doxygen (or similar) formatted comments to kernel-doc or
unformatted comment.  Delete a few that are content-free.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |    9 -
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h    |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h     |   35 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |    4 +-
 drivers/net/ethernet/broadcom/cnic.c               |    2 +-
 drivers/net/ethernet/brocade/bna/bfa_cee.c         |   61 ++----
 drivers/net/ethernet/brocade/bna/bfa_cs.h          |   24 +-
 drivers/net/ethernet/brocade/bna/bfa_defs.h        |   34 ++--
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h    |    9 +-
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |   18 +-
 drivers/net/ethernet/brocade/bna/bfa_defs_status.h |    2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c         |  267 ++++++++++----------
 drivers/net/ethernet/brocade/bna/bfa_ioc.h         |   24 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c      |   24 +-
 drivers/net/ethernet/brocade/bna/bfa_msgq.c        |    4 +-
 drivers/net/ethernet/brocade/bna/bfi.h             |   42 ++--
 drivers/net/ethernet/brocade/bna/bfi_cna.h         |   20 +-
 drivers/net/ethernet/brocade/bna/bfi_enet.h        |   64 +++---
 drivers/net/ethernet/brocade/bna/bfi_reg.h         |    2 +-
 drivers/net/ethernet/brocade/bna/bna.h             |   22 +-
 drivers/net/ethernet/brocade/bna/bna_enet.c        |    6 +-
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h     |   12 +-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |    8 +-
 drivers/net/ethernet/brocade/bna/bna_types.h       |   22 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |    8 +-
 drivers/net/ethernet/brocade/bna/bnad.h            |    2 +-
 drivers/net/ethernet/ibm/ehea/ehea_qmr.c           |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |    8 +-
 drivers/net/ethernet/micrel/ks8851_mll.c           |    4 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.h     |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |    2 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h               |    2 +-
 drivers/net/ethernet/ti/davinci_emac.c             |    4 +-
 36 files changed, 351 insertions(+), 406 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 362d16f..cdd3a8a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1740,15 +1740,6 @@ int bnx2x_set_mac_one(struct bnx2x *bp, u8 *mac,
 		      struct bnx2x_vlan_mac_obj *obj, bool set,
 		      int mac_type, unsigned long *ramrod_flags);
 /**
- * Deletes all MACs configured for the specific MAC object.
- *
- * @param bp Function driver instance
- * @param mac_obj MAC object to cleanup
- *
- * @return zero if all MACs were cleaned
- */
-
-/**
  * bnx2x_del_all_macs - delete all MACs configured for the specific MAC object
  *
  * @bp:			driver handle
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index 426f77a..a014172 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -321,7 +321,7 @@
 #define DISABLE_STATISTIC_COUNTER_ID_VALUE 0
 

-/**
+/*
  * This file defines HSI constants common to all microcode flows
  */
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index c05f9d9..b694619 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -493,7 +493,7 @@ struct bnx2x_ets_params {
 	struct bnx2x_ets_cos_params cos[DCBX_MAX_NUM_COS];
 };
 
-/**
+/*
  * Used to update the PFC attributes in EMAC, BMAC, NIG and BRB
  * when link is already up
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 5b8b521..11e86b4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11560,7 +11560,7 @@ static void bnx2x_prep_ops(const u8 *_source, u8 *_target, u32 n)
 	}
 }
 
-/**
+/*
  * IRO array is stored in the following format:
  * {base(24bit), m1(16bit), m2(16bit), m3(16bit), size(16bit) }
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index f371e3c..726d40c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -7275,7 +7275,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define CDU_REGION_NUMBER_UCM_AG 4
 

-/**
+/*
  * String-to-compress [31:8] = CID (all 24 bits)
  * String-to-compress [7:4] = Region
  * String-to-compress [3:0] = Type
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 76818ef..bf03a04 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -167,8 +167,8 @@ typedef int (*exe_q_remove)(struct bnx2x *bp,
 			    union bnx2x_qable_obj *o,
 			    struct bnx2x_exeq_elem *elem);
 
-/**
- * @return positive is entry was optimized, 0 - if not, negative
+/*
+ * Return positive if entry was optimized, 0 - if not, negative
  *         in case of an error.
  */
 typedef int (*exe_q_optimize)(struct bnx2x *bp,
@@ -1286,12 +1286,11 @@ void bnx2x_init_rx_mode_obj(struct bnx2x *bp,
 			    struct bnx2x_rx_mode_obj *o);
 
 /**
- * Send and RX_MODE ramrod according to the provided parameters.
+ * bnx2x_config_rx_mode - Send and RX_MODE ramrod according to the provided parameters.
  *
- * @param bp
- * @param p Command parameters
+ * @p: Command parameters
  *
- * @return 0 - if operation was successfull and there is no pending completions,
+ * Return: 0 - if operation was successfull and there is no pending completions,
  *         positive number - if there are pending completions,
  *         negative - if there were errors
  */
@@ -1308,7 +1307,11 @@ void bnx2x_init_mcast_obj(struct bnx2x *bp,
 			  bnx2x_obj_type type);
 
 /**
- * Configure multicast MACs list. May configure a new list
+ * bnx2x_config_mcast - Configure multicast MACs list.
+ *
+ * @cmd: command to execute: BNX2X_MCAST_CMD_X
+ *
+ * May configure a new list
  * provided in p->mcast_list (BNX2X_MCAST_CMD_ADD), clean up
  * (BNX2X_MCAST_CMD_DEL) or restore (BNX2X_MCAST_CMD_RESTORE) a current
  * configuration, continue to execute the pending commands
@@ -1319,11 +1322,7 @@ void bnx2x_init_mcast_obj(struct bnx2x *bp,
  * the current command will be enqueued to the tail of the
  * pending commands list.
  *
- * @param bp
- * @param p
- * @param command to execute: BNX2X_MCAST_CMD_X
- *
- * @return 0 is operation was sucessfull and there are no pending completions,
+ * Return: 0 is operation was sucessfull and there are no pending completions,
  *         negative if there were errors, positive if there are pending
  *         completions.
  */
@@ -1348,21 +1347,17 @@ void bnx2x_init_rss_config_obj(struct bnx2x *bp,
 			       bnx2x_obj_type type);
 
 /**
- * Updates RSS configuration according to provided parameters.
- *
- * @param bp
- * @param p
+ * bnx2x_config_rss - Updates RSS configuration according to provided parameters
  *
- * @return 0 in case of success
+ * Return: 0 in case of success
  */
 int bnx2x_config_rss(struct bnx2x *bp,
 		     struct bnx2x_config_rss_params *p);
 
 /**
- * Return the current ind_table configuration.
+ * bnx2x_get_rss_ind_table - Return the current ind_table configuration.
  *
- * @param bp
- * @param ind_table buffer to fill with the current indirection
+ * @ind_table: buffer to fill with the current indirection
  *                  table content. Should be at least
  *                  T_ETH_INDIRECTION_TABLE_SIZE bytes long.
  */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 514a528..0edfd88 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1321,12 +1321,10 @@ static void bnx2x_port_stats_base_init(struct bnx2x *bp)
 	bnx2x_stats_comp(bp);
 }
 
-/**
+/*
  * This function will prepare the statistics ramrod data the way
  * we will only have to increment the statistics counter and
  * send the ramrod each time we have to.
- *
- * @param bp
  */
 static void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
 {
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 22ad7b6..0442d17 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5542,7 +5542,7 @@ static void cnic_rcv_netevent(struct cnic_local *cp, unsigned long event,
 	rcu_read_unlock();
 }
 
-/**
+/*
  * netdev event handler
  */
 static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
diff --git a/drivers/net/ethernet/brocade/bna/bfa_cee.c b/drivers/net/ethernet/brocade/bna/bfa_cee.c
index 689e5e1..9eba009 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cee.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_cee.c
@@ -147,13 +147,7 @@ bfa_cee_reset_stats_isr(struct bfa_cee *cee, enum bfa_status status)
 		cee->cbfn.reset_stats_cbfn(cee->cbfn.reset_stats_cbarg, status);
 }
 /**
- * bfa_nw_cee_meminfo()
- *
- * @brief Returns the size of the DMA memory needed by CEE module
- *
- * @param[in] void
- *
- * @return Size of DMA region
+ * bfa_nw_cee_meminfo - Returns the size of the DMA memory needed by CEE module
  */
 u32
 bfa_nw_cee_meminfo(void)
@@ -162,15 +156,11 @@ bfa_nw_cee_meminfo(void)
 }
 
 /**
- * bfa_nw_cee_mem_claim()
+ * bfa_nw_cee_mem_claim - Initialized CEE DMA Memory
  *
- * @brief Initialized CEE DMA Memory
- *
- * @param[in] cee CEE module pointer
- *	      dma_kva Kernel Virtual Address of CEE DMA Memory
- *	      dma_pa  Physical Address of CEE DMA Memory
- *
- * @return void
+ * @cee: CEE module pointer
+ * @dma_kva: Kernel Virtual Address of CEE DMA Memory
+ * @dma_pa:  Physical Address of CEE DMA Memory
  */
 void
 bfa_nw_cee_mem_claim(struct bfa_cee *cee, u8 *dma_kva, u64 dma_pa)
@@ -185,13 +175,11 @@ bfa_nw_cee_mem_claim(struct bfa_cee *cee, u8 *dma_kva, u64 dma_pa)
 }
 
 /**
- * bfa_cee_get_attr()
+ * bfa_cee_get_attr - Send the request to the f/w to fetch CEE attributes.
  *
- * @brief	Send the request to the f/w to fetch CEE attributes.
+ * @cee: Pointer to the CEE module data structure.
  *
- * @param[in]	Pointer to the CEE module data structure.
- *
- * @return	Status
+ * Return: status
  */
 enum bfa_status
 bfa_nw_cee_get_attr(struct bfa_cee *cee, struct bfa_cee_attr *attr,
@@ -220,13 +208,7 @@ bfa_nw_cee_get_attr(struct bfa_cee *cee, struct bfa_cee_attr *attr,
 }
 
 /**
- * bfa_cee_isrs()
- *
- * @brief Handles Mail-box interrupts for CEE module.
- *
- * @param[in] Pointer to the CEE module data structure.
- *
- * @return void
+ * bfa_cee_isrs - Handles Mail-box interrupts for CEE module.
  */
 
 static void
@@ -253,14 +235,9 @@ bfa_cee_isr(void *cbarg, struct bfi_mbmsg *m)
 }
 
 /**
- * bfa_cee_notify()
- *
- * @brief CEE module heart-beat failure handler.
- * @brief CEE module IOC event handler.
- *
- * @param[in] IOC event type
+ * bfa_cee_notify - CEE module heart-beat failure handler.
  *
- * @return void
+ * @event: IOC event type
  */
 
 static void
@@ -307,17 +284,13 @@ bfa_cee_notify(void *arg, enum bfa_ioc_event event)
 }
 
 /**
- * bfa_nw_cee_attach()
- *
- * @brief CEE module-attach API
+ * bfa_nw_cee_attach - CEE module-attach API
  *
- * @param[in] cee - Pointer to the CEE module data structure
- *            ioc - Pointer to the ioc module data structure
- *            dev - Pointer to the device driver module data structure
- *                  The device driver specific mbox ISR functions have
- *                  this pointer as one of the parameters.
- *
- * @return void
+ * @cee: Pointer to the CEE module data structure
+ * @ioc: Pointer to the ioc module data structure
+ * @dev: Pointer to the device driver module data structure.
+ *       The device driver specific mbox ISR functions have
+ *       this pointer as one of the parameters.
  */
 void
 bfa_nw_cee_attach(struct bfa_cee *cee, struct bfa_ioc *ioc,
diff --git a/drivers/net/ethernet/brocade/bna/bfa_cs.h b/drivers/net/ethernet/brocade/bna/bfa_cs.h
index 3da1a94..6271900 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_cs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_cs.h
@@ -16,8 +16,8 @@
  * www.brocade.com
  */
 
-/**
- * @file bfa_cs.h BFA common services
+/*
+ * BFA common services
  */
 
 #ifndef __BFA_CS_H__
@@ -25,13 +25,13 @@
 
 #include "cna.h"
 
-/**
- * @ BFA state machine interfaces
+/*
+ * BFA state machine interfaces
  */
 
 typedef void (*bfa_sm_t)(void *sm, int event);
 
-/**
+/*
  * oc - object class eg. bfa_ioc
  * st - state, eg. reset
  * otype - object type, eg. struct bfa_ioc
@@ -45,7 +45,7 @@ typedef void (*bfa_sm_t)(void *sm, int event);
 #define bfa_sm_get_state(_sm)		((_sm)->sm)
 #define bfa_sm_cmp_state(_sm, _state)	((_sm)->sm == (bfa_sm_t)(_state))
 
-/**
+/*
  * For converting from state machine function to state encoding.
  */
 struct bfa_sm_table {
@@ -55,12 +55,12 @@ struct bfa_sm_table {
 };
 #define BFA_SM(_sm)		((bfa_sm_t)(_sm))
 
-/**
+/*
  * State machine with entry actions.
  */
 typedef void (*bfa_fsm_t)(void *fsm, int event);
 
-/**
+/*
  * oc - object class eg. bfa_ioc
  * st - state, eg. reset
  * otype - object type, eg. struct bfa_ioc
@@ -90,8 +90,8 @@ bfa_sm_to_state(const struct bfa_sm_table *smt, bfa_sm_t sm)
 	return smt[i].state;
 }
 
-/**
- * @ Generic wait counter.
+/*
+ * Generic wait counter.
  */
 
 typedef void (*bfa_wc_resume_t) (void *cbarg);
@@ -116,7 +116,7 @@ bfa_wc_down(struct bfa_wc *wc)
 		wc->wc_resume(wc->wc_cbarg);
 }
 
-/**
+/*
  * Initialize a waiting counter.
  */
 static inline void
@@ -128,7 +128,7 @@ bfa_wc_init(struct bfa_wc *wc, bfa_wc_resume_t wc_resume, void *wc_cbarg)
 	bfa_wc_up(wc);
 }
 
-/**
+/*
  * Wait for counter to reach zero
  */
 static inline void
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index 48f8773..f4b11a5 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -26,11 +26,11 @@
 #define BFA_STRING_32	32
 #define BFA_VERSION_LEN 64
 
-/**
+/*
  * ---------------------- adapter definitions ------------
  */
 
-/**
+/*
  * BFA adapter level attributes.
  */
 enum {
@@ -74,7 +74,7 @@ struct bfa_adapter_attr {
 	u8		trunk_capable;
 };
 
-/**
+/*
  * ---------------------- IOC definitions ------------
  */
 
@@ -83,7 +83,7 @@ enum {
 	BFA_IOC_CHIP_REV_LEN	= 8,
 };
 
-/**
+/*
  * Driver and firmware versions.
  */
 struct bfa_ioc_driver_attr {
@@ -95,7 +95,7 @@ struct bfa_ioc_driver_attr {
 	char		ob_ver[BFA_VERSION_LEN];	/*!< openboot version */
 };
 
-/**
+/*
  * IOC PCI device attributes
  */
 struct bfa_ioc_pci_attr {
@@ -108,7 +108,7 @@ struct bfa_ioc_pci_attr {
 	char		chip_rev[BFA_IOC_CHIP_REV_LEN];	 /*!< chip revision */
 };
 
-/**
+/*
  * IOC states
  */
 enum bfa_ioc_state {
@@ -127,7 +127,7 @@ enum bfa_ioc_state {
 	BFA_IOC_HWFAIL		= 13,	/*!< PCI mapping doesn't exist */
 };
 
-/**
+/*
  * IOC firmware stats
  */
 struct bfa_fw_ioc_stats {
@@ -139,7 +139,7 @@ struct bfa_fw_ioc_stats {
 	u32	unknown_reqs;
 };
 
-/**
+/*
  * IOC driver stats
  */
 struct bfa_ioc_drv_stats {
@@ -157,7 +157,7 @@ struct bfa_ioc_drv_stats {
 	u32	rsvd;
 };
 
-/**
+/*
  * IOC statistics
  */
 struct bfa_ioc_stats {
@@ -171,7 +171,7 @@ enum bfa_ioc_type {
 	BFA_IOC_TYPE_LL		= 3,
 };
 
-/**
+/*
  * IOC attributes returned in queries
  */
 struct bfa_ioc_attr {
@@ -187,7 +187,7 @@ struct bfa_ioc_attr {
 	u8				rsvd[4];	/*!< 64bit align */
 };
 
-/**
+/*
  * Adapter capability mask definition
  */
 enum {
@@ -196,11 +196,11 @@ enum {
 	BFA_CM_NIC	=	0x04,
 };
 
-/**
+/*
  * ---------------------- mfg definitions ------------
  */
 
-/**
+/*
  * Checksum size
  */
 #define BFA_MFG_CHKSUM_SIZE			16
@@ -213,8 +213,8 @@ enum {
 
 #pragma pack(1)
 
-/**
- * @brief BFA adapter manufacturing block definition.
+/*
+ * BFA adapter manufacturing block definition.
  *
  * All numerical fields are in big-endian format.
  */
@@ -256,7 +256,7 @@ struct bfa_mfg_block {
 
 #pragma pack()
 
-/**
+/*
  * ---------------------- pci definitions ------------
  */
 
@@ -275,7 +275,7 @@ enum {
 #define bfa_asic_id_ctc(device)			\
 	(bfa_asic_id_ct(device) || bfa_asic_id_ct2(device))
 
-/**
+/*
  * PCI sub-system device and vendor ID information
  */
 enum {
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
index 8ab33ee..4554469 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
@@ -20,8 +20,7 @@
 
 #include "bfa_defs.h"
 
-/**
- * @brief
+/*
  * FC physical port statistics.
  */
 struct bfa_port_fc_stats {
@@ -59,8 +58,7 @@ struct bfa_port_fc_stats {
 	u64	bbsc_link_resets; /*!< Credit Recovery-Link Resets   */
 };
 
-/**
- * @brief
+/*
  * Eth Physical Port statistics.
  */
 struct bfa_port_eth_stats {
@@ -108,8 +106,7 @@ struct bfa_port_eth_stats {
 	u64	tx_iscsi_zero_pause; /*!< Tx iSCSI zero pause	*/
 };
 
-/**
- * @brief
+/*
  *		Port statistics.
  */
 union bfa_port_stats_u {
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
index 6681fe8..f619d55 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
@@ -20,23 +20,23 @@
 
 #include "bfa_defs.h"
 
-/**
+/*
  * Manufacturing block version
  */
 #define BFA_MFG_VERSION				3
 #define BFA_MFG_VERSION_UNINIT			0xFF
 
-/**
+/*
  * Manufacturing block encrypted version
  */
 #define BFA_MFG_ENC_VER				2
 
-/**
+/*
  * Manufacturing block version 1 length
  */
 #define BFA_MFG_VER1_LEN			128
 
-/**
+/*
  * Manufacturing block header length
  */
 #define BFA_MFG_HDR_LEN				4
@@ -44,7 +44,7 @@
 #define BFA_MFG_SERIALNUM_SIZE			11
 #define STRSZ(_n)				(((_n) + 4) & ~3)
 
-/**
+/*
  * Manufacturing card type
  */
 enum {
@@ -70,7 +70,7 @@ enum {
 
 #pragma pack(1)
 
-/**
+/*
  * Check if Mezz card
  */
 #define bfa_mfg_is_mezz(type) (( \
@@ -137,7 +137,7 @@ do {								\
 #define BFA_MFG_VPD_PCI_VER_MASK	0x07	/*!< version mask 3 bits */
 #define BFA_MFG_VPD_PCI_VDR_MASK	0xf8	/*!< vendor mask 5 bits */
 
-/**
+/*
  * VPD vendor tag
  */
 enum {
@@ -151,8 +151,8 @@ enum {
 	BFA_MFG_VPD_PCI_BRCD	= 0xf8,  /*!< PCI VPD Brocade		*/
 };
 
-/**
- * @brief BFA adapter flash vpd data definition.
+/*
+ * BFA adapter flash vpd data definition.
  *
  * All numerical fields are in big-endian format.
  */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_status.h b/drivers/net/ethernet/brocade/bna/bfa_defs_status.h
index 7c5fe6c..0cdd438 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_status.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_status.h
@@ -18,7 +18,7 @@
 #ifndef __BFA_DEFS_STATUS_H__
 #define __BFA_DEFS_STATUS_H__
 
-/**
+/*
  * API status return values
  *
  * NOTE: The error msgs are auto generated from the comments. Only singe line
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 0b640fa..ee68a1d 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -20,11 +20,11 @@
 #include "bfi_reg.h"
 #include "bfa_defs.h"
 
-/**
+/*
  * IOC local definitions
  */
 
-/**
+/*
  * Asic specific macros : see bfa_hw_cb.c and bfa_hw_ct.c for details.
  */
 
@@ -96,7 +96,7 @@ static void bfa_ioc_get_adapter_manufacturer(struct bfa_ioc *ioc,
 static void bfa_ioc_get_adapter_model(struct bfa_ioc *ioc, char *model);
 static u64 bfa_ioc_get_pwwn(struct bfa_ioc *ioc);
 
-/**
+/*
  * IOC state machine definitions/declarations
  */
 enum ioc_event {
@@ -148,7 +148,7 @@ static void bfa_iocpf_initfail(struct bfa_ioc *ioc);
 static void bfa_iocpf_getattrfail(struct bfa_ioc *ioc);
 static void bfa_iocpf_stop(struct bfa_ioc *ioc);
 
-/**
+/*
  * IOCPF state machine events
  */
 enum iocpf_event {
@@ -166,7 +166,7 @@ enum iocpf_event {
 	IOCPF_E_SEM_ERROR	= 12,   /*!< h/w sem mapping error	*/
 };
 
-/**
+/*
  * IOCPF states
  */
 enum bfa_iocpf_state {
@@ -215,11 +215,11 @@ static struct bfa_sm_table iocpf_sm_table[] = {
 	{BFA_SM(bfa_iocpf_sm_disabled), BFA_IOCPF_DISABLED},
 };
 
-/**
+/*
  * IOC State Machine
  */
 
-/**
+/*
  * Beginning state. IOC uninit state.
  */
 static void
@@ -227,7 +227,7 @@ bfa_ioc_sm_uninit_entry(struct bfa_ioc *ioc)
 {
 }
 
-/**
+/*
  * IOC is in uninit state.
  */
 static void
@@ -243,7 +243,7 @@ bfa_ioc_sm_uninit(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
-/**
+/*
  * Reset entry actions -- initialize state machine
  */
 static void
@@ -252,7 +252,7 @@ bfa_ioc_sm_reset_entry(struct bfa_ioc *ioc)
 	bfa_fsm_set_state(&ioc->iocpf, bfa_iocpf_sm_reset);
 }
 
-/**
+/*
  * IOC is in reset state.
  */
 static void
@@ -282,7 +282,7 @@ bfa_ioc_sm_enabling_entry(struct bfa_ioc *ioc)
 	bfa_iocpf_enable(ioc);
 }
 
-/**
+/*
  * Host IOC function is being enabled, awaiting response from firmware.
  * Semaphore is acquired.
  */
@@ -325,7 +325,7 @@ bfa_ioc_sm_enabling(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
-/**
+/*
  * Semaphore should be acquired for version check.
  */
 static void
@@ -336,7 +336,7 @@ bfa_ioc_sm_getattr_entry(struct bfa_ioc *ioc)
 	bfa_ioc_send_getattr(ioc);
 }
 
-/**
+/*
  * IOC configuration in progress. Timer is active.
  */
 static void
@@ -419,7 +419,7 @@ bfa_ioc_sm_disabling_entry(struct bfa_ioc *ioc)
 	bfa_iocpf_disable(ioc);
 }
 
-/**
+/*
  * IOC is being disabled
  */
 static void
@@ -449,7 +449,7 @@ bfa_ioc_sm_disabling(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
-/**
+/*
  * IOC disable completion entry.
  */
 static void
@@ -485,7 +485,7 @@ bfa_ioc_sm_fail_retry_entry(struct bfa_ioc *ioc)
 {
 }
 
-/**
+/*
  * Hardware initialization retry.
  */
 static void
@@ -534,7 +534,7 @@ bfa_ioc_sm_fail_entry(struct bfa_ioc *ioc)
 {
 }
 
-/**
+/*
  * IOC failure.
  */
 static void
@@ -568,7 +568,7 @@ bfa_ioc_sm_hwfail_entry(struct bfa_ioc *ioc)
 {
 }
 
-/**
+/*
  * IOC failure.
  */
 static void
@@ -593,11 +593,11 @@ bfa_ioc_sm_hwfail(struct bfa_ioc *ioc, enum ioc_event event)
 	}
 }
 
-/**
+/*
  * IOCPF State Machine
  */
 
-/**
+/*
  * Reset entry actions -- initialize state machine
  */
 static void
@@ -607,7 +607,7 @@ bfa_iocpf_sm_reset_entry(struct bfa_iocpf *iocpf)
 	iocpf->auto_recover = bfa_nw_auto_recover;
 }
 
-/**
+/*
  * Beginning state. IOC is in reset state.
  */
 static void
@@ -626,7 +626,7 @@ bfa_iocpf_sm_reset(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	}
 }
 
-/**
+/*
  * Semaphore should be acquired for version check.
  */
 static void
@@ -636,7 +636,7 @@ bfa_iocpf_sm_fwcheck_entry(struct bfa_iocpf *iocpf)
 	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
-/**
+/*
  * Awaiting h/w semaphore to continue with version check.
  */
 static void
@@ -683,7 +683,7 @@ bfa_iocpf_sm_fwcheck(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	}
 }
 
-/**
+/*
  * Notify enable completion callback
  */
 static void
@@ -698,7 +698,7 @@ bfa_iocpf_sm_mismatch_entry(struct bfa_iocpf *iocpf)
 		msecs_to_jiffies(BFA_IOC_TOV));
 }
 
-/**
+/*
  * Awaiting firmware version match.
  */
 static void
@@ -727,7 +727,7 @@ bfa_iocpf_sm_mismatch(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	}
 }
 
-/**
+/*
  * Request for semaphore.
  */
 static void
@@ -736,7 +736,7 @@ bfa_iocpf_sm_semwait_entry(struct bfa_iocpf *iocpf)
 	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
-/**
+/*
  * Awaiting semaphore for h/w initialzation.
  */
 static void
@@ -778,7 +778,7 @@ bfa_iocpf_sm_hwinit_entry(struct bfa_iocpf *iocpf)
 	bfa_ioc_reset(iocpf->ioc, false);
 }
 
-/**
+/*
  * Hardware is being initialized. Interrupts are enabled.
  * Holding hardware semaphore lock.
  */
@@ -822,7 +822,7 @@ bfa_iocpf_sm_enabling_entry(struct bfa_iocpf *iocpf)
 	bfa_ioc_send_enable(iocpf->ioc);
 }
 
-/**
+/*
  * Host IOC function is being enabled, awaiting response from firmware.
  * Semaphore is acquired.
  */
@@ -896,7 +896,7 @@ bfa_iocpf_sm_disabling_entry(struct bfa_iocpf *iocpf)
 	bfa_ioc_send_disable(iocpf->ioc);
 }
 
-/**
+/*
  * IOC is being disabled
  */
 static void
@@ -935,7 +935,7 @@ bfa_iocpf_sm_disabling_sync_entry(struct bfa_iocpf *iocpf)
 	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
-/**
+/*
  * IOC hb ack request is being removed.
  */
 static void
@@ -963,7 +963,7 @@ bfa_iocpf_sm_disabling_sync(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	}
 }
 
-/**
+/*
  * IOC disable completion entry.
  */
 static void
@@ -1000,7 +1000,7 @@ bfa_iocpf_sm_initfail_sync_entry(struct bfa_iocpf *iocpf)
 	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
-/**
+/*
  * Hardware initialization failed.
  */
 static void
@@ -1046,7 +1046,7 @@ bfa_iocpf_sm_initfail_entry(struct bfa_iocpf *iocpf)
 {
 }
 
-/**
+/*
  * Hardware initialization failed.
  */
 static void
@@ -1084,7 +1084,7 @@ bfa_iocpf_sm_fail_sync_entry(struct bfa_iocpf *iocpf)
 	bfa_ioc_hw_sem_get(iocpf->ioc);
 }
 
-/**
+/*
  * IOC is in failed state.
  */
 static void
@@ -1134,8 +1134,7 @@ bfa_iocpf_sm_fail_entry(struct bfa_iocpf *iocpf)
 {
 }
 
-/**
- * @brief
+/*
  * IOC is in failed state.
  */
 static void
@@ -1151,11 +1150,11 @@ bfa_iocpf_sm_fail(struct bfa_iocpf *iocpf, enum iocpf_event event)
 	}
 }
 
-/**
+/*
  * BFA IOC private functions
  */
 
-/**
+/*
  * Notify common modules registered for notification.
  */
 static void
@@ -1298,8 +1297,7 @@ bfa_ioc_hw_sem_get_cancel(struct bfa_ioc *ioc)
 	del_timer(&ioc->sem_timer);
 }
 
-/**
- * @brief
+/*
  * Initialize LPU local memory (aka secondary memory / SRAM)
  */
 static void
@@ -1366,7 +1364,7 @@ bfa_ioc_lpu_stop(struct bfa_ioc *ioc)
 	writel(pss_ctl, ioc->ioc_regs.pss_ctl_reg);
 }
 
-/**
+/*
  * Get driver and firmware versions.
  */
 void
@@ -1388,7 +1386,7 @@ bfa_nw_ioc_fwver_get(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
 	}
 }
 
-/**
+/*
  * Returns TRUE if same.
  */
 bool
@@ -1408,7 +1406,7 @@ bfa_nw_ioc_fwver_cmp(struct bfa_ioc *ioc, struct bfi_ioc_image_hdr *fwhdr)
 	return true;
 }
 
-/**
+/*
  * Return true if current running version is valid. Firmware signature and
  * execution context (driver/bios) must match.
  */
@@ -1430,7 +1428,7 @@ bfa_ioc_fwver_valid(struct bfa_ioc *ioc, u32 boot_env)
 	return bfa_nw_ioc_fwver_cmp(ioc, &fwhdr);
 }
 
-/**
+/*
  * Conditionally flush any pending message from firmware at start.
  */
 static void
@@ -1443,9 +1441,6 @@ bfa_ioc_msgflush(struct bfa_ioc *ioc)
 		writel(1, ioc->ioc_regs.lpu_mbox_cmd);
 }
 
-/**
- * @img ioc_init_logic.jpg
- */
 static void
 bfa_ioc_hwinit(struct bfa_ioc *ioc, bool force)
 {
@@ -1603,8 +1598,7 @@ bfa_ioc_hb_stop(struct bfa_ioc *ioc)
 	del_timer(&ioc->hb_timer);
 }
 
-/**
- * @brief
+/*
  *	Initiate a full firmware download.
  */
 static void
@@ -1672,7 +1666,7 @@ bfa_ioc_reset(struct bfa_ioc *ioc, bool force)
 	bfa_ioc_hwinit(ioc, force);
 }
 
-/**
+/*
  * BFA ioc enable reply by firmware
  */
 static void
@@ -1686,8 +1680,7 @@ bfa_ioc_enable_reply(struct bfa_ioc *ioc, enum bfa_mode port_mode,
 	bfa_fsm_send_event(iocpf, IOCPF_E_FWRSP_ENABLE);
 }
 
-/**
- * @brief
+/*
  * Update BFA configuration from firmware configuration.
  */
 static void
@@ -1702,7 +1695,7 @@ bfa_ioc_getattr_reply(struct bfa_ioc *ioc)
 	bfa_fsm_send_event(ioc, IOC_E_FWRSP_GETATTR);
 }
 
-/**
+/*
  * Attach time initialization of mbox logic.
  */
 static void
@@ -1718,7 +1711,7 @@ bfa_ioc_mbox_attach(struct bfa_ioc *ioc)
 	}
 }
 
-/**
+/*
  * Mbox poll timer -- restarts any pending mailbox requests.
  */
 static void
@@ -1760,7 +1753,7 @@ bfa_ioc_mbox_poll(struct bfa_ioc *ioc)
 	}
 }
 
-/**
+/*
  * Cleanup any pending requests.
  */
 static void
@@ -1774,12 +1767,12 @@ bfa_ioc_mbox_flush(struct bfa_ioc *ioc)
 }
 
 /**
- * Read data from SMEM to host through PCI memmap
+ * bfa_nw_ioc_smem_read - Read data from SMEM to host through PCI memmap
  *
- * @param[in]  ioc     memory for IOC
- * @param[in]  tbuf    app memory to store data from smem
- * @param[in]  soff    smem offset
- * @param[in]  sz      size of smem in bytes
+ * @ioc:     memory for IOC
+ * @tbuf:    app memory to store data from smem
+ * @soff:    smem offset
+ * @sz:      size of smem in bytes
  */
 static int
 bfa_nw_ioc_smem_read(struct bfa_ioc *ioc, void *tbuf, u32 soff, u32 sz)
@@ -1826,7 +1819,7 @@ bfa_nw_ioc_smem_read(struct bfa_ioc *ioc, void *tbuf, u32 soff, u32 sz)
 	return 0;
 }
 
-/**
+/*
  * Retrieve saved firmware trace from a prior IOC failure.
  */
 int
@@ -1844,7 +1837,7 @@ bfa_nw_ioc_debug_fwtrc(struct bfa_ioc *ioc, void *trcdata, int *trclen)
 	return status;
 }
 
-/**
+/*
  * Save firmware trace if configured.
  */
 static void
@@ -1861,7 +1854,7 @@ bfa_nw_ioc_debug_save_ftrc(struct bfa_ioc *ioc)
 	}
 }
 
-/**
+/*
  * Retrieve saved firmware trace from a prior IOC failure.
  */
 int
@@ -1892,7 +1885,7 @@ bfa_ioc_fail_notify(struct bfa_ioc *ioc)
 	bfa_nw_ioc_debug_save_ftrc(ioc);
 }
 
-/**
+/*
  * IOCPF to IOC interface
  */
 static void
@@ -1928,7 +1921,7 @@ bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc)
 	ioc->cbfn->enable_cbfn(ioc->bfa, BFA_STATUS_IOC_FAILURE);
 }
 
-/**
+/*
  * IOC public
  */
 static enum bfa_status
@@ -1954,7 +1947,7 @@ bfa_ioc_pll_init(struct bfa_ioc *ioc)
 	return BFA_STATUS_OK;
 }
 
-/**
+/*
  * Interface used by diag module to do firmware boot with memory test
  * as the entry vector.
  */
@@ -1983,7 +1976,7 @@ bfa_ioc_boot(struct bfa_ioc *ioc, enum bfi_fwboot_type boot_type,
 	bfa_ioc_lpu_start(ioc);
 }
 
-/**
+/*
  * Enable/disable IOC failure auto recovery.
  */
 void
@@ -2056,10 +2049,10 @@ bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *m)
 }
 
 /**
- * IOC attach time initialization and setup.
+ * bfa_nw_ioc_attach - IOC attach time initialization and setup.
  *
- * @param[in]	ioc	memory for IOC
- * @param[in]	bfa	driver instance structure
+ * @ioc:	memory for IOC
+ * @bfa:	driver instance structure
  */
 void
 bfa_nw_ioc_attach(struct bfa_ioc *ioc, void *bfa, struct bfa_ioc_cbfn *cbfn)
@@ -2078,7 +2071,7 @@ bfa_nw_ioc_attach(struct bfa_ioc *ioc, void *bfa, struct bfa_ioc_cbfn *cbfn)
 	bfa_fsm_send_event(ioc, IOC_E_RESET);
 }
 
-/**
+/*
  * Driver detach time IOC cleanup.
  */
 void
@@ -2091,9 +2084,9 @@ bfa_nw_ioc_detach(struct bfa_ioc *ioc)
 }
 
 /**
- * Setup IOC PCI properties.
+ * bfa_nw_ioc_pci_init - Setup IOC PCI properties.
  *
- * @param[in]	pcidev	PCI device information for this IOC
+ * @pcidev:	PCI device information for this IOC
  */
 void
 bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
@@ -2160,10 +2153,10 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 }
 
 /**
- * Initialize IOC dma memory
+ * bfa_nw_ioc_mem_claim - Initialize IOC dma memory
  *
- * @param[in]	dm_kva	kernel virtual address of IOC dma memory
- * @param[in]	dm_pa	physical address of IOC dma memory
+ * @dm_kva:	kernel virtual address of IOC dma memory
+ * @dm_pa:	physical address of IOC dma memory
  */
 void
 bfa_nw_ioc_mem_claim(struct bfa_ioc *ioc,  u8 *dm_kva, u64 dm_pa)
@@ -2176,7 +2169,7 @@ bfa_nw_ioc_mem_claim(struct bfa_ioc *ioc,  u8 *dm_kva, u64 dm_pa)
 	ioc->attr = (struct bfi_ioc_attr *) dm_kva;
 }
 
-/**
+/*
  * Return size of dma memory required.
  */
 u32
@@ -2201,7 +2194,7 @@ bfa_nw_ioc_disable(struct bfa_ioc *ioc)
 	bfa_fsm_send_event(ioc, IOC_E_DISABLE);
 }
 
-/**
+/*
  * Initialize memory for saving firmware trace.
  */
 void
@@ -2217,7 +2210,7 @@ bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr)
 	return PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, fmaddr);
 }
 
-/**
+/*
  * Register mailbox message handler function, to be called by common modules
  */
 void
@@ -2231,11 +2224,12 @@ bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 }
 
 /**
- * Queue a mailbox command request to firmware. Waits if mailbox is busy.
- * Responsibility of caller to serialize
+ * bfa_nw_ioc_mbox_queue - Queue a mailbox command request to firmware.
  *
- * @param[in]	ioc	IOC instance
- * @param[i]	cmd	Mailbox command
+ * @ioc:	IOC instance
+ * @cmd:	Mailbox command
+ *
+ * Waits if mailbox is busy. Responsibility of caller to serialize
  */
 bool
 bfa_nw_ioc_mbox_queue(struct bfa_ioc *ioc, struct bfa_mbox_cmd *cmd,
@@ -2272,7 +2266,7 @@ bfa_nw_ioc_mbox_queue(struct bfa_ioc *ioc, struct bfa_mbox_cmd *cmd,
 	return false;
 }
 
-/**
+/*
  * Handle mailbox interrupts
  */
 void
@@ -2314,7 +2308,7 @@ bfa_nw_ioc_error_isr(struct bfa_ioc *ioc)
 	bfa_fsm_send_event(ioc, IOC_E_HWERROR);
 }
 
-/**
+/*
  * return true if IOC is disabled
  */
 bool
@@ -2324,7 +2318,7 @@ bfa_nw_ioc_is_disabled(struct bfa_ioc *ioc)
 		bfa_fsm_cmp_state(ioc, bfa_ioc_sm_disabled);
 }
 
-/**
+/*
  * return true if IOC is operational
  */
 bool
@@ -2333,7 +2327,7 @@ bfa_nw_ioc_is_operational(struct bfa_ioc *ioc)
 	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_op);
 }
 
-/**
+/*
  * Add to IOC heartbeat failure notification queue. To be used by common
  * modules such as cee, port, diag.
  */
@@ -2518,7 +2512,7 @@ bfa_nw_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr)
 	bfa_ioc_get_pci_chip_rev(ioc, ioc_attr->pci_attr.chip_rev);
 }
 
-/**
+/*
  * WWN public
  */
 static u64
@@ -2533,7 +2527,7 @@ bfa_nw_ioc_get_mac(struct bfa_ioc *ioc)
 	return ioc->attr->mac;
 }
 
-/**
+/*
  * Firmware failure detected. Start recovery actions.
  */
 static void
@@ -2545,9 +2539,8 @@ bfa_ioc_recover(struct bfa_ioc *ioc)
 	bfa_fsm_send_event(ioc, IOC_E_HBFAIL);
 }
 
-/**
- * @dg hal_iocpf_pvt BFA IOC PF private functions
- * @{
+/*
+ * BFA IOC PF private functions
  */
 
 static void
@@ -2669,8 +2662,6 @@ bfa_flash_notify(void *cbarg, enum bfa_ioc_event event)
 
 /*
  * Send flash write request.
- *
- * @param[in] cbarg - callback argument
  */
 static void
 bfa_flash_write_send(struct bfa_flash *flash)
@@ -2699,10 +2690,10 @@ bfa_flash_write_send(struct bfa_flash *flash)
 	flash->offset += len;
 }
 
-/*
- * Send flash read request.
+/**
+ * bfa_flash_read_send - Send flash read request.
  *
- * @param[in] cbarg - callback argument
+ * @cbarg: callback argument
  */
 static void
 bfa_flash_read_send(void *cbarg)
@@ -2724,11 +2715,11 @@ bfa_flash_read_send(void *cbarg)
 	bfa_nw_ioc_mbox_queue(flash->ioc, &flash->mb, NULL, NULL);
 }
 
-/*
- * Process flash response messages upon receiving interrupts.
+/**
+ * bfa_flash_intr - Process flash response messages upon receiving interrupts.
  *
- * @param[in] flasharg - flash structure
- * @param[in] msg - message structure
+ * @flasharg: flash structure
+ * @msg: message structure
  */
 static void
 bfa_flash_intr(void *flasharg, struct bfi_mbmsg *msg)
@@ -2821,12 +2812,12 @@ bfa_nw_flash_meminfo(void)
 	return roundup(BFA_FLASH_DMA_BUF_SZ, BFA_DMA_ALIGN_SZ);
 }
 
-/*
- * Flash attach API.
+/**
+ * bfa_nw_flash_attach - Flash attach API.
  *
- * @param[in] flash - flash structure
- * @param[in] ioc  - ioc structure
- * @param[in] dev  - device structure
+ * @flash: flash structure
+ * @ioc: ioc structure
+ * @dev: device structure
  */
 void
 bfa_nw_flash_attach(struct bfa_flash *flash, struct bfa_ioc *ioc, void *dev)
@@ -2842,12 +2833,12 @@ bfa_nw_flash_attach(struct bfa_flash *flash, struct bfa_ioc *ioc, void *dev)
 	list_add_tail(&flash->ioc_notify.qe, &flash->ioc->notify_q);
 }
 
-/*
- * Claim memory for flash
+/**
+ * bfa_nw_flash_memclaim - Claim memory for flash
  *
- * @param[in] flash - flash structure
- * @param[in] dm_kva - pointer to virtual memory address
- * @param[in] dm_pa - physical memory address
+ * @flash: flash structure
+ * @dm_kva: pointer to virtual memory address
+ * @dm_pa: physical memory address
  */
 void
 bfa_nw_flash_memclaim(struct bfa_flash *flash, u8 *dm_kva, u64 dm_pa)
@@ -2859,13 +2850,13 @@ bfa_nw_flash_memclaim(struct bfa_flash *flash, u8 *dm_kva, u64 dm_pa)
 	dm_pa += roundup(BFA_FLASH_DMA_BUF_SZ, BFA_DMA_ALIGN_SZ);
 }
 
-/*
- * Get flash attribute.
+/**
+ * bfa_nw_flash_get_attr - Get flash attribute.
  *
- * @param[in] flash - flash structure
- * @param[in] attr - flash attribute structure
- * @param[in] cbfn - callback function
- * @param[in] cbarg - callback argument
+ * @flash: flash structure
+ * @attr: flash attribute structure
+ * @cbfn: callback function
+ * @cbarg: callback argument
  *
  * Return status.
  */
@@ -2895,17 +2886,17 @@ bfa_nw_flash_get_attr(struct bfa_flash *flash, struct bfa_flash_attr *attr,
 	return BFA_STATUS_OK;
 }
 
-/*
- * Update flash partition.
+/**
+ * bfa_nw_flash_update_part - Update flash partition.
  *
- * @param[in] flash - flash structure
- * @param[in] type - flash partition type
- * @param[in] instance - flash partition instance
- * @param[in] buf - update data buffer
- * @param[in] len - data buffer length
- * @param[in] offset - offset relative to the partition starting address
- * @param[in] cbfn - callback function
- * @param[in] cbarg - callback argument
+ * @flash: flash structure
+ * @type: flash partition type
+ * @instance: flash partition instance
+ * @buf: update data buffer
+ * @len: data buffer length
+ * @offset: offset relative to the partition starting address
+ * @cbfn: callback function
+ * @cbarg: callback argument
  *
  * Return status.
  */
@@ -2944,17 +2935,17 @@ bfa_nw_flash_update_part(struct bfa_flash *flash, u32 type, u8 instance,
 	return BFA_STATUS_OK;
 }
 
-/*
- * Read flash partition.
+/**
+ * bfa_nw_flash_read_part - Read flash partition.
  *
- * @param[in] flash - flash structure
- * @param[in] type - flash partition type
- * @param[in] instance - flash partition instance
- * @param[in] buf - read data buffer
- * @param[in] len - data buffer length
- * @param[in] offset - offset relative to the partition starting address
- * @param[in] cbfn - callback function
- * @param[in] cbarg - callback argument
+ * @flash: flash structure
+ * @type: flash partition type
+ * @instance: flash partition instance
+ * @buf: read data buffer
+ * @len: data buffer length
+ * @offset: offset relative to the partition starting address
+ * @cbfn: callback function
+ * @cbarg: callback argument
  *
  * Return status.
  */
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index 3b4460fd..dabbd62 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -30,7 +30,7 @@
 #define BNA_DBG_FWTRC_LEN      (BFI_IOC_TRC_ENTS * BFI_IOC_TRC_ENT_SZ + \
 				BFI_IOC_TRC_HDR_SZ)
 
-/**
+/*
  * PCI device information required by IOC
  */
 struct bfa_pcidev {
@@ -41,7 +41,7 @@ struct bfa_pcidev {
 	void	__iomem *pci_bar_kva;
 };
 
-/**
+/*
  * Structure used to remember the DMA-able memory block's KVA and Physical
  * Address
  */
@@ -52,14 +52,14 @@ struct bfa_dma {
 
 #define BFA_DMA_ALIGN_SZ	256
 
-/**
+/*
  * smem size for Crossbow and Catapult
  */
 #define BFI_SMEM_CB_SIZE	0x200000U	/* ! 2MB for crossbow	*/
 #define BFI_SMEM_CT_SIZE	0x280000U	/* ! 2.5MB for catapult	*/
 
-/**
- * @brief BFA dma address assignment macro. (big endian format)
+/*
+ * BFA dma address assignment macro. (big endian format)
  */
 #define bfa_dma_be_addr_set(dma_addr, pa)	\
 		__bfa_dma_be_addr_set(&dma_addr, (u64)pa)
@@ -108,7 +108,7 @@ struct bfa_ioc_regs {
 	u32	smem_pg0;
 };
 
-/**
+/*
  * IOC Mailbox structures
  */
 typedef void (*bfa_mbox_cmd_cbfn_t)(void *cbarg);
@@ -119,7 +119,7 @@ struct bfa_mbox_cmd {
 	u32     msg[BFI_IOC_MSGSZ];
 };
 
-/**
+/*
  * IOC mailbox module
  */
 typedef void (*bfa_ioc_mbox_mcfunc_t)(void *cbarg, struct bfi_mbmsg *m);
@@ -132,7 +132,7 @@ struct bfa_ioc_mbox_mod {
 	} mbhdlr[BFI_MC_MAX];
 };
 
-/**
+/*
  * IOC callback function interfaces
  */
 typedef void (*bfa_ioc_enable_cbfn_t)(void *bfa, enum bfa_status status);
@@ -146,7 +146,7 @@ struct bfa_ioc_cbfn {
 	bfa_ioc_reset_cbfn_t	reset_cbfn;
 };
 
-/**
+/*
  * IOC event notification mechanism.
  */
 enum bfa_ioc_event {
@@ -163,7 +163,7 @@ struct bfa_ioc_notify {
 	void			*cbarg;
 };
 
-/**
+/*
  * Initialize a IOC event notification structure
  */
 #define bfa_ioc_notify_init(__notify, __cbfn, __cbarg) do {	\
@@ -261,7 +261,7 @@ struct bfa_ioc_hwif {
 #define BFA_IOC_FLASH_OFFSET_IN_CHUNK(off)	(off % BFI_FLASH_CHUNK_SZ_WORDS)
 #define BFA_IOC_FLASH_CHUNK_ADDR(chunkno)  (chunkno * BFI_FLASH_CHUNK_SZ_WORDS)
 
-/**
+/*
  * IOC mailbox interface
  */
 bool bfa_nw_ioc_mbox_queue(struct bfa_ioc *ioc,
@@ -271,7 +271,7 @@ void bfa_nw_ioc_mbox_isr(struct bfa_ioc *ioc);
 void bfa_nw_ioc_mbox_regisr(struct bfa_ioc *ioc, enum bfi_mclass mc,
 		bfa_ioc_mbox_mcfunc_t cbfn, void *cbarg);
 
-/**
+/*
  * IOC interfaces
  */
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
index b6b036a..b9ad8e7 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
@@ -87,7 +87,7 @@ static const struct bfa_ioc_hwif nw_hwif_ct2 = {
 	.ioc_sync_complete   = bfa_ioc_ct_sync_complete,
 };
 
-/**
+/*
  * Called from bfa_ioc_attach() to map asic specific calls.
  */
 void
@@ -102,7 +102,7 @@ bfa_nw_ioc_set_ct2_hwif(struct bfa_ioc *ioc)
 	ioc->ioc_hwif = &nw_hwif_ct2;
 }
 
-/**
+/*
  * Return true if firmware of current driver matches the running firmware.
  */
 static bool
@@ -182,7 +182,7 @@ bfa_ioc_ct_firmware_unlock(struct bfa_ioc *ioc)
 	bfa_nw_ioc_sem_release(ioc->ioc_regs.ioc_usage_sem_reg);
 }
 
-/**
+/*
  * Notify other functions on HB failure.
  */
 static void
@@ -195,7 +195,7 @@ bfa_ioc_ct_notify_fail(struct bfa_ioc *ioc)
 	readl(ioc->ioc_regs.alt_ll_halt);
 }
 
-/**
+/*
  * Host to LPU mailbox message addresses
  */
 static const struct {
@@ -209,7 +209,7 @@ static const struct {
 	{ HOSTFN3_LPU_MBOX0_8, LPU_HOSTFN3_MBOX0_8, HOST_PAGE_NUM_FN3 }
 };
 
-/**
+/*
  * Host <-> LPU mailbox command/status registers - port 0
  */
 static const struct {
@@ -222,7 +222,7 @@ static const struct {
 	{ HOSTFN3_LPU0_CMD_STAT, LPU0_HOSTFN3_CMD_STAT }
 };
 
-/**
+/*
  * Host <-> LPU mailbox command/status registers - port 1
  */
 static const struct {
@@ -368,7 +368,7 @@ bfa_ioc_ct2_reg_init(struct bfa_ioc *ioc)
 	ioc->ioc_regs.err_set = rb + ERR_SET_REG;
 }
 
-/**
+/*
  * Initialize IOC to port mapping.
  */
 
@@ -398,7 +398,7 @@ bfa_ioc_ct2_map_port(struct bfa_ioc *ioc)
 	ioc->port_id = ((r32 & __FC_LL_PORT_MAP__MK) >> __FC_LL_PORT_MAP__SH);
 }
 
-/**
+/*
  * Set interrupt mode for a function: INTX or MSIX
  */
 static void
@@ -443,7 +443,7 @@ bfa_ioc_ct2_lpu_read_stat(struct bfa_ioc *ioc)
 	return false;
 }
 
-/**
+/*
  * MSI-X resource allocation for 1860 with no asic block
  */
 #define HOSTFN_MSIX_DEFAULT		64
@@ -473,7 +473,7 @@ bfa_nw_ioc_ct2_poweron(struct bfa_ioc *ioc)
 			rb + HOSTFN_MSIX_VT_INDEX_MBOX_ERR);
 }
 
-/**
+/*
  * Cleanup hw semaphore and usecnt registers
  */
 static void
@@ -492,7 +492,7 @@ bfa_ioc_ct_ownership_reset(struct bfa_ioc *ioc)
 	bfa_nw_ioc_hw_sem_release(ioc);
 }
 
-/**
+/*
  * Synchronized IOC failure processing routines
  */
 static bool
@@ -518,7 +518,7 @@ bfa_ioc_ct_sync_start(struct bfa_ioc *ioc)
 
 	return bfa_ioc_ct_sync_complete(ioc);
 }
-/**
+/*
  * Synchronized IOC failure processing routines
  */
 static void
diff --git a/drivers/net/ethernet/brocade/bna/bfa_msgq.c b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
index dd36427..6b6dcff 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_msgq.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_msgq.c
@@ -16,8 +16,8 @@
  * www.brocade.com
  */
 
-/**
- * @file bfa_msgq.c MSGQ module source file.
+/*
+ * MSGQ module source file.
  */
 
 #include "bfi.h"
diff --git a/drivers/net/ethernet/brocade/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
index 0d9df69..fd55776 100644
--- a/drivers/net/ethernet/brocade/bna/bfi.h
+++ b/drivers/net/ethernet/brocade/bna/bfi.h
@@ -22,13 +22,13 @@
 
 #pragma pack(1)
 
-/**
+/*
  * BFI FW image type
  */
 #define	BFI_FLASH_CHUNK_SZ			256	/*!< Flash chunk size */
 #define	BFI_FLASH_CHUNK_SZ_WORDS	(BFI_FLASH_CHUNK_SZ/sizeof(u32))
 
-/**
+/*
  * Msg header common to all msgs
  */
 struct bfi_mhdr {
@@ -65,7 +65,7 @@ struct bfi_mhdr {
 #define BFI_I2H_OPCODE_BASE	128
 #define BFA_I2HM(_x)			((_x) + BFI_I2H_OPCODE_BASE)
 
-/**
+/*
  ****************************************************************************
  *
  * Scatter Gather Element and Page definition
@@ -73,7 +73,7 @@ struct bfi_mhdr {
  ****************************************************************************
  */
 
-/**
+/*
  * DMA addresses
  */
 union bfi_addr_u {
@@ -83,7 +83,7 @@ union bfi_addr_u {
 	} a32;
 };
 
-/**
+/*
  * Generic DMA addr-len pair.
  */
 struct bfi_alen {
@@ -98,7 +98,7 @@ struct bfi_alen {
 #define BFI_LMSG_PL_WSZ	\
 			((BFI_LMSG_SZ - sizeof(struct bfi_mhdr)) / 4)
 
-/**
+/*
  * Mailbox message structure
  */
 #define BFI_MBMSG_SZ		7
@@ -107,7 +107,7 @@ struct bfi_mbmsg {
 	u32		pl[BFI_MBMSG_SZ];
 };
 
-/**
+/*
  * Supported PCI function class codes (personality)
  */
 enum bfi_pcifn_class {
@@ -115,7 +115,7 @@ enum bfi_pcifn_class {
 	BFI_PCIFN_CLASS_ETH	= 0x0200,
 };
 
-/**
+/*
  * Message Classes
  */
 enum bfi_mclass {
@@ -159,13 +159,13 @@ enum bfi_mclass {
 
 #define BFI_FWBOOT_ENV_OS		0
 
-/**
+/*
  *----------------------------------------------------------------------
  *				IOC
  *----------------------------------------------------------------------
  */
 
-/**
+/*
  * Different asic generations
  */
 enum bfi_asic_gen {
@@ -196,7 +196,7 @@ enum bfi_ioc_i2h_msgs {
 	BFI_IOC_I2H_HBEAT		= BFA_I2HM(4),
 };
 
-/**
+/*
  * BFI_IOC_H2I_GETATTR_REQ message
  */
 struct bfi_ioc_getattr_req {
@@ -231,7 +231,7 @@ struct bfi_ioc_attr {
 	u32	card_type;	/*!< card type			*/
 };
 
-/**
+/*
  * BFI_IOC_I2H_GETATTR_REPLY message
  */
 struct bfi_ioc_getattr_reply {
@@ -240,19 +240,19 @@ struct bfi_ioc_getattr_reply {
 	u8			rsvd[3];
 };
 
-/**
+/*
  * Firmware memory page offsets
  */
 #define BFI_IOC_SMEM_PG0_CB	(0x40)
 #define BFI_IOC_SMEM_PG0_CT	(0x180)
 
-/**
+/*
  * Firmware statistic offset
  */
 #define BFI_IOC_FWSTATS_OFF	(0x6B40)
 #define BFI_IOC_FWSTATS_SZ	(4096)
 
-/**
+/*
  * Firmware trace offset
  */
 #define BFI_IOC_TRC_OFF		(0x4b00)
@@ -299,7 +299,7 @@ struct bfi_ioc_hbeat {
 	u32	   hb_count;	/*!< current heart beat count	*/
 };
 
-/**
+/*
  * IOC hardware/firmware state
  */
 enum bfi_ioc_state {
@@ -345,7 +345,7 @@ enum {
 	((__adap_type) & (BFI_ADAPTER_TTV | BFI_ADAPTER_PROTO |	\
 			BFI_ADAPTER_UNSUPP))
 
-/**
+/*
  * BFI_IOC_H2I_ENABLE_REQ & BFI_IOC_H2I_DISABLE_REQ messages
  */
 struct bfi_ioc_ctrl_req {
@@ -355,7 +355,7 @@ struct bfi_ioc_ctrl_req {
 	u32		tv_sec;
 };
 
-/**
+/*
  * BFI_IOC_I2H_ENABLE_REPLY & BFI_IOC_I2H_DISABLE_REPLY messages
  */
 struct bfi_ioc_ctrl_reply {
@@ -367,7 +367,7 @@ struct bfi_ioc_ctrl_reply {
 };
 
 #define BFI_IOC_MSGSZ   8
-/**
+/*
  * H2I Messages
  */
 union bfi_ioc_h2i_msg_u {
@@ -378,7 +378,7 @@ union bfi_ioc_h2i_msg_u {
 	u32			mboxmsg[BFI_IOC_MSGSZ];
 };
 
-/**
+/*
  * I2H Messages
  */
 union bfi_ioc_i2h_msg_u {
@@ -387,7 +387,7 @@ union bfi_ioc_i2h_msg_u {
 	u32			mboxmsg[BFI_IOC_MSGSZ];
 };
 
-/**
+/*
  *----------------------------------------------------------------------
  *				MSGQ
  *----------------------------------------------------------------------
diff --git a/drivers/net/ethernet/brocade/bna/bfi_cna.h b/drivers/net/ethernet/brocade/bna/bfi_cna.h
index 4eecabe..a22b0a2 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_cna.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_cna.h
@@ -37,7 +37,7 @@ enum bfi_port_i2h {
 	BFI_PORT_I2H_CLEAR_STATS_RSP	= BFA_I2HM(4),
 };
 
-/**
+/*
  * Generic REQ type
  */
 struct bfi_port_generic_req {
@@ -46,7 +46,7 @@ struct bfi_port_generic_req {
 	u32	rsvd;
 };
 
-/**
+/*
  * Generic RSP type
  */
 struct bfi_port_generic_rsp {
@@ -56,25 +56,25 @@ struct bfi_port_generic_rsp {
 	u32	msgtag;		/*!< msgtag for reply		    */
 };
 
-/**
+/*
  * @todo
  * BFI_PORT_H2I_ENABLE_REQ
  */
 
-/**
+/*
  * @todo
  * BFI_PORT_I2H_ENABLE_RSP
  */
 
-/**
+/*
  * BFI_PORT_H2I_DISABLE_REQ
  */
 
-/**
+/*
  * BFI_PORT_I2H_DISABLE_RSP
  */
 
-/**
+/*
  * BFI_PORT_H2I_GET_STATS_REQ
  */
 struct bfi_port_get_stats_req {
@@ -82,15 +82,15 @@ struct bfi_port_get_stats_req {
 	union bfi_addr_u   dma_addr;
 };
 
-/**
+/*
  * BFI_PORT_I2H_GET_STATS_RSP
  */
 
-/**
+/*
  * BFI_PORT_H2I_CLEAR_STATS_REQ
  */
 
-/**
+/*
  * BFI_PORT_I2H_CLEAR_STATS_RSP
  */
 
diff --git a/drivers/net/ethernet/brocade/bna/bfi_enet.h b/drivers/net/ethernet/brocade/bna/bfi_enet.h
index a90f1cf..351d71e 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_enet.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_enet.h
@@ -16,11 +16,11 @@
  * www.brocade.com
  */
 
-/**
- * @file bfi_enet.h BNA Hardware and Firmware Interface
+/*
+ * BNA Hardware and Firmware Interface
  */
 
-/**
+/*
  * Skipping statistics collection to avoid clutter.
  * Command is no longer needed:
  *	MTU
@@ -64,7 +64,7 @@ union bfi_addr_be_u {
 	} a32;
 };
 
-/**
+/*
  *	T X   Q U E U E   D E F I N E S
  */
 /* TxQ Vector (a.k.a. Tx-Buffer Descriptor) */
@@ -106,7 +106,7 @@ struct bfi_enet_txq_wi_vector {			/* Tx Buffer Descriptor */
 	union bfi_addr_be_u	addr;
 };
 
-/**
+/*
  *  TxQ Entry Structure
  *
  */
@@ -124,14 +124,14 @@ struct bfi_enet_txq_entry {
 #define BFI_ENET_TXQ_WI_L4_HDR_N_OFFSET(_hdr_size, _offset) \
 		(((_hdr_size) << 10) | ((_offset) & 0x3FF))
 
-/**
+/*
  *   R X   Q U E U E   D E F I N E S
  */
 struct bfi_enet_rxq_entry {
 	union bfi_addr_be_u  rx_buffer;
 };
 
-/**
+/*
  *   R X   C O M P L E T I O N   Q U E U E   D E F I N E S
  */
 /* CQ Entry Flags */
@@ -174,7 +174,7 @@ struct bfi_enet_cq_entry {
 	u8	rxq_id;
 };
 
-/**
+/*
  *   E N E T   C O N T R O L   P A T H   C O M M A N D S
  */
 struct bfi_enet_q {
@@ -222,7 +222,7 @@ struct bfi_enet_ib {
 	u16		rsvd;
 };
 
-/**
+/*
  * ENET command messages
  */
 enum bfi_enet_h2i_msgs {
@@ -350,7 +350,7 @@ enum bfi_enet_i2h_msgs {
 	BFI_ENET_I2H_BW_UPDATE_AEN = BFA_I2HM(BFI_ENET_H2I_MAX + 4),
 };
 
-/**
+/*
  *  The following error codes can be returned by the enet commands
  */
 enum bfi_enet_err {
@@ -364,7 +364,7 @@ enum bfi_enet_err {
 	BFI_ENET_CMD_PORT_DISABLED = 7,	/* !< port in disabled state */
 };
 
-/**
+/*
  * Generic Request
  *
  * bfi_enet_req is used by:
@@ -375,7 +375,7 @@ struct bfi_enet_req {
 	struct bfi_msgq_mhdr mh;
 };
 
-/**
+/*
  * Enable/Disable Request
  *
  * bfi_enet_enable_req is used by:
@@ -391,7 +391,7 @@ struct bfi_enet_enable_req {
 	u8		rsvd[3];
 };
 
-/**
+/*
  * Generic Response
  */
 struct bfi_enet_rsp {
@@ -401,11 +401,11 @@ struct bfi_enet_rsp {
 	u16		cmd_offset;	/*!< offset to invalid parameter */
 };
 
-/**
+/*
  * GLOBAL CONFIGURATION
  */
 
-/**
+/*
  * bfi_enet_attr_req is used by:
  *	BFI_ENET_H2I_GET_ATTR_REQ
  */
@@ -413,7 +413,7 @@ struct bfi_enet_attr_req {
 	struct bfi_msgq_mhdr	mh;
 };
 
-/**
+/*
  * bfi_enet_attr_rsp is used by:
  *	BFI_ENET_I2H_GET_ATTR_RSP
  */
@@ -427,7 +427,7 @@ struct bfi_enet_attr_rsp {
 	u32		rit_size;
 };
 
-/**
+/*
  * Tx Configuration
  *
  * bfi_enet_tx_cfg is used by:
@@ -477,7 +477,7 @@ struct bfi_enet_tx_cfg_rsp {
 	} q_handles[BFI_ENET_TXQ_PRIO_MAX];
 };
 
-/**
+/*
  * Rx Configuration
  *
  * bfi_enet_rx_cfg is used by:
@@ -553,7 +553,7 @@ struct bfi_enet_rx_cfg_rsp {
 	} q_handles[BFI_ENET_RX_QSET_MAX];
 };
 
-/**
+/*
  * RIT
  *
  * bfi_enet_rit_req is used by:
@@ -566,7 +566,7 @@ struct bfi_enet_rit_req {
 	u8	table[BFI_ENET_RSS_RIT_MAX];
 };
 
-/**
+/*
  * RSS
  *
  * bfi_enet_rss_cfg_req is used by:
@@ -591,7 +591,7 @@ struct bfi_enet_rss_cfg_req {
 	struct bfi_enet_rss_cfg	cfg;
 };
 
-/**
+/*
  * MAC Unicast
  *
  * bfi_enet_rx_vlan_req is used by:
@@ -606,7 +606,7 @@ struct bfi_enet_ucast_req {
 	u8			rsvd[2];
 };
 
-/**
+/*
  * MAC Unicast + VLAN
  */
 struct bfi_enet_mac_n_vlan_req {
@@ -615,7 +615,7 @@ struct bfi_enet_mac_n_vlan_req {
 	mac_t			mac_addr;
 };
 
-/**
+/*
  * MAC Multicast
  *
  * bfi_enet_mac_mfilter_add_req is used by:
@@ -627,7 +627,7 @@ struct bfi_enet_mcast_add_req {
 	u8			rsvd[2];
 };
 
-/**
+/*
  * bfi_enet_mac_mfilter_add_rsp is used by:
  *	BFI_ENET_I2H_MAC_MCAST_ADD_RSP
  */
@@ -640,7 +640,7 @@ struct bfi_enet_mcast_add_rsp {
 	u8			rsvd1[2];
 };
 
-/**
+/*
  * bfi_enet_mac_mfilter_del_req is used by:
  *	BFI_ENET_H2I_MAC_MCAST_DEL_REQ
  */
@@ -650,7 +650,7 @@ struct bfi_enet_mcast_del_req {
 	u8			rsvd[2];
 };
 
-/**
+/*
  * VLAN
  *
  * bfi_enet_rx_vlan_req is used by:
@@ -663,7 +663,7 @@ struct bfi_enet_rx_vlan_req {
 	u32			bit_mask[BFI_ENET_VLAN_WORDS_MAX];
 };
 
-/**
+/*
  * PAUSE
  *
  * bfi_enet_set_pause_req is used by:
@@ -676,7 +676,7 @@ struct bfi_enet_set_pause_req {
 	u8			rx_pause;	/* 1 = enable;  0 = disable */
 };
 
-/**
+/*
  * DIAGNOSTICS
  *
  * bfi_enet_diag_lb_req is used by:
@@ -689,7 +689,7 @@ struct bfi_enet_diag_lb_req {
 	u8			enable;		/* 1 = enable;  0 = disable */
 };
 
-/**
+/*
  * enum for Loopback opmodes
  */
 enum {
@@ -697,7 +697,7 @@ enum {
 	BFI_ENET_DIAG_LB_OPMODE_CBL = 1,
 };
 
-/**
+/*
  * STATISTICS
  *
  * bfi_enet_stats_req is used by:
@@ -713,7 +713,7 @@ struct bfi_enet_stats_req {
 	union bfi_addr_u	host_buffer;
 };
 
-/**
+/*
  * defines for "stats_mask" above.
  */
 #define BFI_ENET_STATS_MAC    (1 << 0)    /* !< MAC Statistics */
@@ -881,7 +881,7 @@ struct bfi_enet_stats_mac {
 	u64 tx_fragments;
 };
 
-/**
+/*
  * Complete statistics, DMAed from fw to host followed by
  * BFI_ENET_I2H_STATS_GET_RSP
  */
diff --git a/drivers/net/ethernet/brocade/bna/bfi_reg.h b/drivers/net/ethernet/brocade/bna/bfi_reg.h
index 0e094fe..6497cb5 100644
--- a/drivers/net/ethernet/brocade/bna/bfi_reg.h
+++ b/drivers/net/ethernet/brocade/bna/bfi_reg.h
@@ -221,7 +221,7 @@ enum {
 #define __PMM_1T_RESET_P		0x00000001
 #define PMM_1T_RESET_REG_P1		0x00023c1c
 
-/**
+/*
  * Brocade 1860 Adapter specific defines
  */
 #define CT2_PCI_CPQ_BASE		0x00030000
diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 4d7a5de..58aded5 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -25,7 +25,7 @@
 
 extern const u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
 
-/**
+/*
  *
  *  Macros and constants
  *
@@ -356,7 +356,7 @@ do {									\
 	}								\
 } while (0)
 
-/**
+/*
  *
  *  Inline functions
  *
@@ -377,13 +377,13 @@ static inline struct bna_mac *bna_mac_find(struct list_head *q, u8 *addr)
 
 #define bna_attr(_bna) (&(_bna)->ioceth.attr)
 
-/**
+/*
  *
  * Function prototypes
  *
  */
 
-/**
+/*
  * BNA
  */
 
@@ -413,14 +413,14 @@ struct bna_mcam_handle *bna_mcam_mod_handle_get(struct bna_mcam_mod *mod);
 void bna_mcam_mod_handle_put(struct bna_mcam_mod *mcam_mod,
 			  struct bna_mcam_handle *handle);
 
-/**
+/*
  * MBOX
  */
 
 /* API for BNAD */
 void bna_mbox_handler(struct bna *bna, u32 intr_status);
 
-/**
+/*
  * ETHPORT
  */
 
@@ -428,7 +428,7 @@ void bna_mbox_handler(struct bna *bna, u32 intr_status);
 void bna_ethport_cb_rx_started(struct bna_ethport *ethport);
 void bna_ethport_cb_rx_stopped(struct bna_ethport *ethport);
 
-/**
+/*
  * TX MODULE AND TX
  */
 /* FW response handelrs */
@@ -462,7 +462,7 @@ void bna_tx_disable(struct bna_tx *tx, enum bna_cleanup_type type,
 void bna_tx_cleanup_complete(struct bna_tx *tx);
 void bna_tx_coalescing_timeo_set(struct bna_tx *tx, int coalescing_timeo);
 
-/**
+/*
  * RX MODULE, RX, RXF
  */
 
@@ -522,7 +522,7 @@ bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode rxmode,
 void bna_rx_vlan_add(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlan_del(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlanfilter_enable(struct bna_rx *rx);
-/**
+/*
  * ENET
  */
 
@@ -544,7 +544,7 @@ void bna_enet_mtu_set(struct bna_enet *enet, int mtu,
 		      void (*cbfn)(struct bnad *));
 void bna_enet_perm_mac_get(struct bna_enet *enet, mac_t *mac);
 
-/**
+/*
  * IOCETH
  */
 
@@ -553,7 +553,7 @@ void bna_ioceth_enable(struct bna_ioceth *ioceth);
 void bna_ioceth_disable(struct bna_ioceth *ioceth,
 			enum bna_cleanup_type type);
 
-/**
+/*
  * BNAD
  */
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index 9ccc586..fa52a2c 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -378,7 +378,7 @@ bna_msgq_rsp_handler(void *arg, struct bfi_msgq_mhdr *msghdr)
 	}
 }
 
-/**
+/*
  * ETHPORT
  */
 #define call_ethport_stop_cbfn(_ethport)				\
@@ -804,7 +804,7 @@ bna_ethport_cb_rx_stopped(struct bna_ethport *ethport)
 	}
 }
 
-/**
+/*
  * ENET
  */
 #define bna_enet_chld_start(enet)					\
@@ -1328,7 +1328,7 @@ bna_enet_perm_mac_get(struct bna_enet *enet, mac_t *mac)
 	*mac = bfa_nw_ioc_get_mac(&enet->bna->ioceth.ioc);
 }
 
-/**
+/*
  * IOCETH
  */
 #define enable_mbox_intr(_ioceth)					\
diff --git a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
index 4c6aab2..e606b35 100644
--- a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
@@ -16,7 +16,7 @@
  * www.brocade.com
  */
 
-/**
+/*
  * File for interrupt macros and functions
  */
 
@@ -25,7 +25,7 @@
 
 #include "bfi_reg.h"
 
-/**
+/*
  *
  * SW imposed limits
  *
@@ -141,7 +141,7 @@
 }
 
 #define bna_port_id_get(_bna) ((_bna)->ioceth.ioc.port_id)
-/**
+/*
  *
  *  Interrupt related bits, flags and macros
  *
@@ -280,7 +280,7 @@ do {									\
 	(writel(BNA_DOORBELL_Q_PRD_IDX((_rcb)->producer_index), \
 		(_rcb)->q_dbell));
 
-/**
+/*
  *
  * TxQ, RxQ, CQ related bits, offsets, macros
  *
@@ -334,7 +334,7 @@ do {									\
 
 #define	BNA_CQ_EF_LOCAL		(1 << 20)
 
-/**
+/*
  *
  * Data structures
  *
@@ -371,7 +371,7 @@ struct bna_txq_wi_vector {
 	struct bna_dma_addr host_addr; /* Tx-Buf DMA addr */
 };
 
-/**
+/*
  *  TxQ Entry Structure
  *
  *  BEWARE:  Load values into this structure with correct endianess.
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 276fcb5..53e7bb1 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -18,7 +18,7 @@
 #include "bna.h"
 #include "bfi.h"
 
-/**
+/*
  * IB
  */
 static void
@@ -29,7 +29,7 @@ bna_ib_coalescing_timeo_set(struct bna_ib *ib, u8 coalescing_timeo)
 				(u32)ib->coalescing_timeo, 0);
 }
 
-/**
+/*
  * RXF
  */
 
@@ -1312,7 +1312,7 @@ bna_rxf_vlan_strip_cfg_apply(struct bna_rxf *rxf)
 	return 0;
 }
 
-/**
+/*
  * RX
  */
 
@@ -2791,7 +2791,7 @@ const u32 bna_napi_dim_vector[BNA_LOAD_T_MAX][BNA_BIAS_T_MAX] = {
 	{1, 2},
 };
 
-/**
+/*
  * TX
  */
 #define call_tx_stop_cbfn(tx)						\
diff --git a/drivers/net/ethernet/brocade/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
index e8d3ab7..8957b04 100644
--- a/drivers/net/ethernet/brocade/bna/bna_types.h
+++ b/drivers/net/ethernet/brocade/bna/bna_types.h
@@ -23,7 +23,7 @@
 #include "bfa_cee.h"
 #include "bfa_msgq.h"
 
-/**
+/*
  *
  * Forward declarations
  *
@@ -40,7 +40,7 @@ struct bna_enet;
 struct bna;
 struct bnad;
 
-/**
+/*
  *
  * Enums, primitive data types
  *
@@ -331,7 +331,7 @@ struct bna_attr {
 	int			max_rit_size;
 };
 
-/**
+/*
  *
  * IOCEth
  *
@@ -351,7 +351,7 @@ struct bna_ioceth {
 	struct bna *bna;
 };
 
-/**
+/*
  *
  * Enet
  *
@@ -390,7 +390,7 @@ struct bna_enet {
 	struct bna *bna;
 };
 
-/**
+/*
  *
  * Ethport
  *
@@ -419,7 +419,7 @@ struct bna_ethport {
 	struct bna *bna;
 };
 
-/**
+/*
  *
  * Interrupt Block
  *
@@ -447,7 +447,7 @@ struct bna_ib {
 	int			interpkt_timeo;
 };
 
-/**
+/*
  *
  * Tx object
  *
@@ -585,7 +585,7 @@ struct bna_tx_mod {
 	struct bna *bna;
 };
 
-/**
+/*
  *
  * Rx object
  *
@@ -898,7 +898,7 @@ struct bna_rx_mod {
 	u32		rid_mask;
 };
 
-/**
+/*
  *
  * CAM
  *
@@ -927,7 +927,7 @@ struct bna_mcam_mod {
 	struct bna *bna;
 };
 
-/**
+/*
  *
  * Statistics
  *
@@ -949,7 +949,7 @@ struct bna_stats_mod {
 	struct bfi_enet_stats_req stats_clr;
 };
 
-/**
+/*
  *
  * BNA
  *
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 67cd2ed0..50b4644 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -1302,7 +1302,7 @@ bnad_txrx_irq_alloc(struct bnad *bnad, enum bnad_intr_source src,
 	return 0;
 }
 
-/**
+/*
  * NOTE: Should be called for MSIX only
  * Unregisters Tx MSIX vector(s) from the kernel
  */
@@ -1322,7 +1322,7 @@ bnad_tx_msix_unregister(struct bnad *bnad, struct bnad_tx_info *tx_info,
 	}
 }
 
-/**
+/*
  * NOTE: Should be called for MSIX only
  * Registers Tx MSIX vector(s) and ISR(s), cookie with the kernel
  */
@@ -1354,7 +1354,7 @@ err_return:
 	return -1;
 }
 
-/**
+/*
  * NOTE: Should be called for MSIX only
  * Unregisters Rx MSIX vector(s) from the kernel
  */
@@ -1375,7 +1375,7 @@ bnad_rx_msix_unregister(struct bnad *bnad, struct bnad_rx_info *rx_info,
 	}
 }
 
-/**
+/*
  * NOTE: Should be called for MSIX only
  * Registers Tx MSIX vector(s) and ISR(s), cookie with the kernel
  */
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 72742be..508434e 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -389,7 +389,7 @@ extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
 void	bnad_debugfs_init(struct bnad *bnad);
 void	bnad_debugfs_uninit(struct bnad *bnad);
 
-/**
+/*
  * MACROS
  */
 /* To set & get the stats counters */
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
index 4fb47f1..116abb4 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
@@ -376,7 +376,7 @@ int ehea_destroy_eq(struct ehea_eq *eq)
 	return 0;
 }
 
-/**
+/*
  * allocates memory for a queue and registers pages in phyp
  */
 static int ehea_qp_alloc_register(struct ehea_qp *qp, struct hw_queue *hw_queue,
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 183a4a3..4eea851 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -721,9 +721,9 @@ void e1000_reset(struct e1000_adapter *adapter)
 	e1000_release_manageability(adapter);
 }
 
-/**
+/*
  *  Dump the eeprom for users having checksum issues
- **/
+ */
 static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -3056,14 +3056,14 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 	mmiowb();
 }
 
-/**
+/*
  * 82547 workaround to avoid controller hang in half-duplex environment.
  * The workaround is to avoid queuing a large packet that would span
  * the internal Tx FIFO ring boundary by notifying the stack to resend
  * the packet at a later time.  This gives the Tx FIFO an opportunity to
  * flush all packets.  When that occurs, we reset the Tx FIFO pointers
  * to the beginning of the Tx FIFO.
- **/
+ */
 
 #define E1000_FIFO_HDR			0x10
 #define E1000_82547_PAD_LEN		0x3E0
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index 76bf159..e4a7445 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -16,7 +16,7 @@
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
 
-/**
+/*
  * Supports:
  * KS8851 16bit MLL chip from Micrel Inc.
  */
@@ -465,7 +465,7 @@ static int msg_enable;
 #define BE1             0x2000      /* Byte Enable 1 */
 #define BE0             0x1000      /* Byte Enable 0 */
 
-/**
+/*
  * register read/write calls.
  *
  * All these calls issue transactions to access the chip's registers. They
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.h b/drivers/net/ethernet/neterion/vxge/vxge-main.h
index 35f3e75..bc5bb73 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.h
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.h
@@ -430,7 +430,7 @@ void vxge_initialize_ethtool_ops(struct net_device *ndev);
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
 int vxge_fw_upgrade(struct vxgedev *vdev, char *fw_name, int override);
 
-/**
+/*
  * #define VXGE_DEBUG_INIT: debug for initialization functions
  * #define VXGE_DEBUG_TX	 : debug transmit related functions
  * #define VXGE_DEBUG_RX  : debug recevice related functions
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index c503fbe..51d7047 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3552,7 +3552,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 	return IRQ_HANDLED;
 }
 
-/**
+/*
  * All _optimized functions are used to help increase performance
  * (reduce CPU and increase throughput). They use descripter version 3,
  * compiler directives, and reduce memory accesses.
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index 0310b9f0..13838e2 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -48,7 +48,7 @@
 
 /* Unused commands: 0x23, 0x27, 0x30, 0x31 */
 
-/**
+/*
  * MCDI version 1
  *
  * Each MCDI request starts with an MCDI_HEADER, which is a 32byte
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 9cdd619..acdfd26 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -614,7 +614,7 @@ static int emac_set_coalesce(struct net_device *ndev,
 }
 

-/**
+/*
  * ethtool_ops: DaVinci EMAC Ethtool structure
  *
  * Ethtool support for EMAC adapter
@@ -2015,7 +2015,7 @@ static const struct dev_pm_ops davinci_emac_pm_ops = {
 	.resume		= davinci_emac_resume,
 };
 
-/**
+/*
  * davinci_emac_driver: EMAC platform driver structure
  */
 static struct platform_driver davinci_emac_driver = {
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

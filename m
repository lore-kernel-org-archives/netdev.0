From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] drivers/net: use __packed annotation
Date: Thu, 03 Jun 2010 06:10:09 +0200
Message-ID: <1275538209.29413.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:35312 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab0FCEKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 00:10:22 -0400
Received: by wwb28 with SMTP id 28so3486369wwb.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 21:10:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cleanup patch.

Use new __packed annotation in drivers/net/

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/3c527.h                            |    6 
 drivers/net/8139cp.c                           |    2 
 drivers/net/atlx/atl1.h                        |    4 
 drivers/net/can/mscan/mscan.h                  |    2 
 drivers/net/can/usb/ems_usb.c                  |    2 
 drivers/net/dm9000.c                           |    2 
 drivers/net/ehea/ehea_qmr.h                    |    2 
 drivers/net/enic/vnic_vic.h                    |    2 
 drivers/net/fsl_pq_mdio.h                      |    2 
 drivers/net/irda/donauboe.h                    |    2 
 drivers/net/irda/irda-usb.h                    |    2 
 drivers/net/irda/ks959-sir.c                   |    2 
 drivers/net/irda/ksdazzle-sir.c                |    2 
 drivers/net/irda/vlsi_ir.h                     |    6 
 drivers/net/mlx4/eq.c                          |   14 
 drivers/net/mlx4/mr.c                          |    2 
 drivers/net/ps3_gelic_wireless.h               |   10 
 drivers/net/qlge/qlge.h                        |   24 -
 drivers/net/sfc/selftest.c                     |    2 
 drivers/net/sky2.h                             |    6 
 drivers/net/tehuti.h                           |    2 
 drivers/net/tulip/de2104x.c                    |    4 
 drivers/net/typhoon.c                          |    2 
 drivers/net/typhoon.h                          |   26 -
 drivers/net/ucc_geth.h                         |   46 +-
 drivers/net/usb/asix.c                         |    2 
 drivers/net/usb/hso.c                          |    2 
 drivers/net/usb/kaweth.c                       |    2 
 drivers/net/usb/net1080.c                      |    4 
 drivers/net/usb/sierra_net.c                   |    2 
 drivers/net/via-velocity.h                     |   12 
 drivers/net/wan/hd64570.h                      |    2 
 drivers/net/wan/hdlc_cisco.c                   |    4 
 drivers/net/wan/hdlc_fr.c                      |    2 
 drivers/net/wan/sdla.c                         |    2 
 drivers/net/wimax/i2400m/control.c             |    2 
 drivers/net/wimax/i2400m/fw.c                  |    8 
 drivers/net/wimax/i2400m/op-rfkill.c           |    2 
 drivers/net/wireless/adm8211.h                 |    6 
 drivers/net/wireless/airo.c                    |   32 -
 drivers/net/wireless/at76c50x-usb.c            |    2 
 drivers/net/wireless/at76c50x-usb.h            |   40 +-
 drivers/net/wireless/b43/b43.h                 |    6 
 drivers/net/wireless/b43/dma.h                 |    8 
 drivers/net/wireless/b43/xmit.h                |   20 -
 drivers/net/wireless/b43legacy/b43legacy.h     |    6 
 drivers/net/wireless/b43legacy/dma.h           |    8 
 drivers/net/wireless/b43legacy/xmit.h          |   10 
 drivers/net/wireless/hostap/hostap_80211.h     |   18 -
 drivers/net/wireless/hostap/hostap_common.h    |   10 
 drivers/net/wireless/hostap/hostap_wlan.h      |   32 -
 drivers/net/wireless/ipw2x00/ipw2100.c         |    4 
 drivers/net/wireless/ipw2x00/ipw2100.h         |   16 
 drivers/net/wireless/ipw2x00/ipw2200.h         |  122 +++----
 drivers/net/wireless/ipw2x00/libipw.h          |   62 +--
 drivers/net/wireless/iwlwifi/iwl-3945-fh.h     |    4 
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h     |   10 
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h     |    2 
 drivers/net/wireless/iwlwifi/iwl-agn-hw.h      |    2 
 drivers/net/wireless/iwlwifi/iwl-commands.h    |  244 +++++++--------
 drivers/net/wireless/iwlwifi/iwl-dev.h         |    8 
 drivers/net/wireless/iwlwifi/iwl-eeprom.h      |   12 
 drivers/net/wireless/iwlwifi/iwl-fh.h          |    6 
 drivers/net/wireless/iwlwifi/iwl-spectrum.h    |   10 
 drivers/net/wireless/iwmc3200wifi/commands.h   |   50 +--
 drivers/net/wireless/iwmc3200wifi/iwm.h        |    2 
 drivers/net/wireless/iwmc3200wifi/lmac.h       |   32 -
 drivers/net/wireless/iwmc3200wifi/umac.h       |   60 +--
 drivers/net/wireless/libertas/host.h           |  120 +++----
 drivers/net/wireless/libertas/radiotap.h       |    4 
 drivers/net/wireless/libertas/rx.c             |    8 
 drivers/net/wireless/libertas/types.h          |   66 ++--
 drivers/net/wireless/libertas_tf/libertas_tf.h |    4 
 drivers/net/wireless/mac80211_hwsim.c          |    2 
 drivers/net/wireless/mwl8k.c                   |   66 ++--
 drivers/net/wireless/orinoco/fw.c              |    2 
 drivers/net/wireless/orinoco/hermes.h          |   18 -
 drivers/net/wireless/orinoco/hermes_dld.c      |    8 
 drivers/net/wireless/orinoco/hw.c              |    6 
 drivers/net/wireless/orinoco/main.c            |   10 
 drivers/net/wireless/orinoco/orinoco.h         |    2 
 drivers/net/wireless/orinoco/orinoco_usb.c     |    4 
 drivers/net/wireless/orinoco/wext.c            |    2 
 drivers/net/wireless/p54/net2280.h             |   16 
 drivers/net/wireless/p54/p54pci.h              |    6 
 drivers/net/wireless/p54/p54spi.h              |    2 
 drivers/net/wireless/p54/p54usb.h              |    6 
 drivers/net/wireless/prism54/isl_ioctl.c       |    2 
 drivers/net/wireless/prism54/isl_oid.h         |   18 -
 drivers/net/wireless/prism54/islpci_eth.h      |    4 
 drivers/net/wireless/prism54/islpci_mgt.h      |    2 
 drivers/net/wireless/rndis_wlan.c              |   34 +-
 drivers/net/wireless/rt2x00/rt2800.h           |    6 
 drivers/net/wireless/rt2x00/rt61pci.h          |    4 
 drivers/net/wireless/rt2x00/rt73usb.h          |    4 
 drivers/net/wireless/rtl818x/rtl8180.h         |    4 
 drivers/net/wireless/rtl818x/rtl8187.h         |    8 
 drivers/net/wireless/rtl818x/rtl818x.h         |    2 
 drivers/net/wireless/wl12xx/wl1251_acx.h       |  102 +++---
 drivers/net/wireless/wl12xx/wl1251_cmd.h       |   22 -
 drivers/net/wireless/wl12xx/wl1251_event.h     |    4 
 drivers/net/wireless/wl12xx/wl1251_rx.h        |    2 
 drivers/net/wireless/wl12xx/wl1251_tx.h        |    6 
 drivers/net/wireless/wl12xx/wl1271.h           |    4 
 drivers/net/wireless/wl12xx/wl1271_acx.h       |  102 +++---
 drivers/net/wireless/wl12xx/wl1271_cmd.h       |   40 +-
 drivers/net/wireless/wl12xx/wl1271_event.h     |    4 
 drivers/net/wireless/wl12xx/wl1271_rx.h        |    2 
 drivers/net/wireless/wl12xx/wl1271_tx.h        |    6 
 drivers/net/wireless/wl12xx/wl12xx_80211.h     |   26 -
 drivers/net/wireless/wl3501.h                  |   16 
 drivers/net/wireless/zd1211rw/zd_mac.h         |   12 
 drivers/net/wireless/zd1211rw/zd_usb.h         |   14 
 113 files changed, 934 insertions(+), 934 deletions(-)

diff --git a/drivers/net/3c527.h b/drivers/net/3c527.h
index 75e28fe..d693b8d 100644
--- a/drivers/net/3c527.h
+++ b/drivers/net/3c527.h
@@ -34,7 +34,7 @@ struct mc32_mailbox
 {
  	u16 mbox;
  	u16 data[1];
-} __attribute((packed));
+} __packed;
 
 struct skb_header
 {
@@ -43,7 +43,7 @@ struct skb_header
 	u16 next;	/* Do not change! */
 	u16 length;
 	u32 data;
-} __attribute((packed));
+} __packed;
 
 struct mc32_stats
 {
@@ -68,7 +68,7 @@ struct mc32_stats
 	u32 dataA[6];
 	u16 dataB[5];
 	u32 dataC[14];
-} __attribute((packed));
+} __packed;
 
 #define STATUS_MASK	0x0F
 #define COMPLETED	(1<<7)
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 9c14975..e949ba8 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -322,7 +322,7 @@ struct cp_dma_stats {
 	__le32			rx_ok_mcast;
 	__le16			tx_abort;
 	__le16			tx_underrun;
-} __attribute__((packed));
+} __packed;
 
 struct cp_extra_stats {
 	unsigned long		rx_frags;
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 146372f..9c0ddb2 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -436,8 +436,8 @@ struct rx_free_desc {
 	__le16 buf_len;		/* Size of the receive buffer in host memory */
 	u16 coalese;		/* Update consumer index to host after the
 				 * reception of this frame */
-	/* __attribute__ ((packed)) is required */
-} __attribute__ ((packed));
+	/* __packed is required */
+} __packed;
 
 /*
  * The L1 transmit packet descriptor is comprised of four 32-bit words.
diff --git a/drivers/net/can/mscan/mscan.h b/drivers/net/can/mscan/mscan.h
index 4ff9664..b43e9f5 100644
--- a/drivers/net/can/mscan/mscan.h
+++ b/drivers/net/can/mscan/mscan.h
@@ -227,7 +227,7 @@ struct mscan_regs {
 		u16 time;			/* + 0x7c     0x3e */
 	} tx;
 	_MSCAN_RESERVED_(32, 2);		/* + 0x7e          */
-} __attribute__ ((packed));
+} __packed;
 
 #undef _MSCAN_RESERVED_
 #define MSCAN_REGION 	sizeof(struct mscan)
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index 1fc0871..e75f1a8 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -197,7 +197,7 @@ struct cpc_can_err_counter {
 };
 
 /* Main message type used between library and application */
-struct __attribute__ ((packed)) ems_cpc_msg {
+struct __packed ems_cpc_msg {
 	u8 type;	/* type of message */
 	u8 length;	/* length of data within union 'msg' */
 	u8 msgid;	/* confirmation handle */
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index abcc838..4fd6b2b 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -961,7 +961,7 @@ struct dm9000_rxhdr {
 	u8	RxPktReady;
 	u8	RxStatus;
 	__le16	RxLen;
-} __attribute__((__packed__));
+} __packed;
 
 /*
  *  Received a packet and pass to upper layer
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index 882c50c..f608a6c 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -126,7 +126,7 @@ struct ehea_swqe {
 			u8 immediate_data[SWQE2_MAX_IMM];
 			/* 0xd0 */
 			struct ehea_vsgentry sg_list[EHEA_MAX_WQE_SG_ENTRIES-1];
-		} immdata_desc __attribute__ ((packed));
+		} immdata_desc __packed;
 
 		/*  Send WQE Format 3 */
 		struct {
diff --git a/drivers/net/enic/vnic_vic.h b/drivers/net/enic/vnic_vic.h
index 085c2a2..7e46e5e 100644
--- a/drivers/net/enic/vnic_vic.h
+++ b/drivers/net/enic/vnic_vic.h
@@ -44,7 +44,7 @@ struct vic_provinfo {
 		u16 length;
 		u8 value[0];
 	} tlv[0];
-} __attribute__ ((packed));
+} __packed;
 
 #define VIC_PROVINFO_MAX_DATA		1385
 #define VIC_PROVINFO_MAX_TLV_DATA (VIC_PROVINFO_MAX_DATA - \
diff --git a/drivers/net/fsl_pq_mdio.h b/drivers/net/fsl_pq_mdio.h
index 1f7d865..bd17a2a 100644
--- a/drivers/net/fsl_pq_mdio.h
+++ b/drivers/net/fsl_pq_mdio.h
@@ -39,7 +39,7 @@ struct fsl_pq_mdio {
 	u8 reserved[28];	/* Space holder */
 	u32 utbipar;		/* TBI phy address reg (only on UCC) */
 	u8 res4[2728];
-} __attribute__ ((packed));
+} __packed;
 
 int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
 int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
diff --git a/drivers/net/irda/donauboe.h b/drivers/net/irda/donauboe.h
index 0dbd193..36c3060 100644
--- a/drivers/net/irda/donauboe.h
+++ b/drivers/net/irda/donauboe.h
@@ -273,7 +273,7 @@ struct OboeSlot
   __u8 control;                 /*Slot control/status see below */
   __u32 address;                /*Slot buffer address */
 }
-__attribute__ ((packed));
+__packed;
 
 #define OBOE_NTASKS OBOE_TXRING_OFFSET_IN_SLOTS
 
diff --git a/drivers/net/irda/irda-usb.h b/drivers/net/irda/irda-usb.h
index ac0443d..58ddb52 100644
--- a/drivers/net/irda/irda-usb.h
+++ b/drivers/net/irda/irda-usb.h
@@ -125,7 +125,7 @@ struct irda_class_desc {
 	__u8  bmAdditionalBOFs;
 	__u8  bIrdaRateSniff;
 	__u8  bMaxUnicastList;
-} __attribute__ ((packed));
+} __packed;
 
 /* class specific interface request to get the IrDA-USB class descriptor
  * (6.2.5, USB-IrDA class spec 1.0) */
diff --git a/drivers/net/irda/ks959-sir.c b/drivers/net/irda/ks959-sir.c
index b54d3b4..1046014 100644
--- a/drivers/net/irda/ks959-sir.c
+++ b/drivers/net/irda/ks959-sir.c
@@ -154,7 +154,7 @@ struct ks959_speedparams {
 	__le32 baudrate;	/* baud rate, little endian */
 	__u8 flags;
 	__u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 #define KS_DATA_5_BITS 0x00
 #define KS_DATA_6_BITS 0x01
diff --git a/drivers/net/irda/ksdazzle-sir.c b/drivers/net/irda/ksdazzle-sir.c
index 8d713eb..9cc142f 100644
--- a/drivers/net/irda/ksdazzle-sir.c
+++ b/drivers/net/irda/ksdazzle-sir.c
@@ -117,7 +117,7 @@ struct ksdazzle_speedparams {
 	__le32 baudrate;	/* baud rate, little endian */
 	__u8 flags;
 	__u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 #define KS_DATA_5_BITS 0x00
 #define KS_DATA_6_BITS 0x01
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/net/irda/vlsi_ir.h
index 3050d1a..3f24a1f 100644
--- a/drivers/net/irda/vlsi_ir.h
+++ b/drivers/net/irda/vlsi_ir.h
@@ -544,9 +544,9 @@ struct ring_descr_hw {
 		struct {
 			u8		addr_res[3];
 			volatile u8	status;		/* descriptor status */
-		} __attribute__((packed)) rd_s;
-	} __attribute((packed)) rd_u;
-} __attribute__ ((packed));
+		} __packed rd_s;
+	} __packed rd_u;
+} __packed;
 
 #define rd_addr		rd_u.addr
 #define rd_status	rd_u.rd_s.status
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 4230534..22d0b3b 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -110,7 +110,7 @@ struct mlx4_eqe {
 		u32		raw[6];
 		struct {
 			__be32	cqn;
-		} __attribute__((packed)) comp;
+		} __packed comp;
 		struct {
 			u16	reserved1;
 			__be16	token;
@@ -118,27 +118,27 @@ struct mlx4_eqe {
 			u8	reserved3[3];
 			u8	status;
 			__be64	out_param;
-		} __attribute__((packed)) cmd;
+		} __packed cmd;
 		struct {
 			__be32	qpn;
-		} __attribute__((packed)) qp;
+		} __packed qp;
 		struct {
 			__be32	srqn;
-		} __attribute__((packed)) srq;
+		} __packed srq;
 		struct {
 			__be32	cqn;
 			u32	reserved1;
 			u8	reserved2[3];
 			u8	syndrome;
-		} __attribute__((packed)) cq_err;
+		} __packed cq_err;
 		struct {
 			u32	reserved1[2];
 			__be32	port;
-		} __attribute__((packed)) port_change;
+		} __packed port_change;
 	}			event;
 	u8			reserved3[3];
 	u8			owner;
-} __attribute__((packed));
+} __packed;
 
 static void eq_set_ci(struct mlx4_eq *eq, int req_not)
 {
diff --git a/drivers/net/mlx4/mr.c b/drivers/net/mlx4/mr.c
index 3dc69be..9c188bd 100644
--- a/drivers/net/mlx4/mr.c
+++ b/drivers/net/mlx4/mr.c
@@ -58,7 +58,7 @@ struct mlx4_mpt_entry {
 	__be32 mtt_sz;
 	__be32 entity_size;
 	__be32 first_byte_offset;
-} __attribute__((packed));
+} __packed;
 
 #define MLX4_MPT_FLAG_SW_OWNS	    (0xfUL << 28)
 #define MLX4_MPT_FLAG_FREE	    (0x3UL << 28)
diff --git a/drivers/net/ps3_gelic_wireless.h b/drivers/net/ps3_gelic_wireless.h
index 0a88b53..f7e51b7 100644
--- a/drivers/net/ps3_gelic_wireless.h
+++ b/drivers/net/ps3_gelic_wireless.h
@@ -74,7 +74,7 @@ struct gelic_eurus_common_cfg {
 	u16 bss_type;    /* infra or adhoc */
 	u16 auth_method; /* shared key or open */
 	u16 op_mode; /* B/G */
-} __attribute__((packed));
+} __packed;
 
 
 /* for GELIC_EURUS_CMD_WEP_CFG */
@@ -88,7 +88,7 @@ struct gelic_eurus_wep_cfg {
 	/* all fields are big endian */
 	u16 security;
 	u8 key[4][16];
-} __attribute__((packed));
+} __packed;
 
 /* for GELIC_EURUS_CMD_WPA_CFG */
 enum gelic_eurus_wpa_security {
@@ -120,7 +120,7 @@ struct gelic_eurus_wpa_cfg {
 	u16 security;
 	u16 psk_type; /* psk key encoding type */
 	u8 psk[GELIC_WL_EURUS_PSK_MAX_LEN]; /* psk key; hex or passphrase */
-} __attribute__((packed));
+} __packed;
 
 /* for GELIC_EURUS_CMD_{START,GET}_SCAN */
 enum gelic_eurus_scan_capability {
@@ -171,7 +171,7 @@ struct gelic_eurus_scan_info {
 	__be32 reserved3;
 	__be32 reserved4;
 	u8 elements[0]; /* ie */
-} __attribute__ ((packed));
+} __packed;
 
 /* the hypervisor returns bbs up to 16 */
 #define GELIC_EURUS_MAX_SCAN  (16)
@@ -193,7 +193,7 @@ struct gelic_wl_scan_info {
 struct gelic_eurus_rssi_info {
 	/* big endian */
 	__be16 rssi;
-} __attribute__ ((packed));
+} __packed;
 
 
 /* for 'stat' member of gelic_wl_info */
diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 20624ba..bfb8b32 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1062,7 +1062,7 @@ struct tx_buf_desc {
 #define TX_DESC_LEN_MASK	0x000fffff
 #define TX_DESC_C	0x40000000
 #define TX_DESC_E	0x80000000
-} __attribute((packed));
+} __packed;
 
 /*
  * IOCB Definitions...
@@ -1095,7 +1095,7 @@ struct ob_mac_iocb_req {
 	__le16 vlan_tci;
 	__le16 reserved4;
 	struct tx_buf_desc tbd[TX_DESC_PER_IOCB];
-} __attribute((packed));
+} __packed;
 
 struct ob_mac_iocb_rsp {
 	u8 opcode;		/* */
@@ -1112,7 +1112,7 @@ struct ob_mac_iocb_rsp {
 	u32 tid;
 	u32 txq_idx;
 	__le32 reserved[13];
-} __attribute((packed));
+} __packed;
 
 struct ob_mac_tso_iocb_req {
 	u8 opcode;
@@ -1140,7 +1140,7 @@ struct ob_mac_tso_iocb_req {
 	__le16 vlan_tci;
 	__le16 mss;
 	struct tx_buf_desc tbd[TX_DESC_PER_IOCB];
-} __attribute((packed));
+} __packed;
 
 struct ob_mac_tso_iocb_rsp {
 	u8 opcode;
@@ -1157,7 +1157,7 @@ struct ob_mac_tso_iocb_rsp {
 	u32 tid;
 	u32 txq_idx;
 	__le32 reserved2[13];
-} __attribute((packed));
+} __packed;
 
 struct ib_mac_iocb_rsp {
 	u8 opcode;		/* 0x20 */
@@ -1216,7 +1216,7 @@ struct ib_mac_iocb_rsp {
 #define IB_MAC_IOCB_RSP_HL	0x80
 	__le32 hdr_len;		/* */
 	__le64 hdr_addr;	/* */
-} __attribute((packed));
+} __packed;
 
 struct ib_ae_iocb_rsp {
 	u8 opcode;
@@ -1237,7 +1237,7 @@ struct ib_ae_iocb_rsp {
 #define PCI_ERR_ANON_BUF_RD        0x40
 	u8 q_id;
 	__le32 reserved[15];
-} __attribute((packed));
+} __packed;
 
 /*
  * These three structures are for generic
@@ -1249,7 +1249,7 @@ struct ql_net_rsp_iocb {
 	__le16 length;
 	__le32 tid;
 	__le32 reserved[14];
-} __attribute((packed));
+} __packed;
 
 struct net_req_iocb {
 	u8 opcode;
@@ -1257,7 +1257,7 @@ struct net_req_iocb {
 	__le16 flags1;
 	__le32 tid;
 	__le32 reserved1[30];
-} __attribute((packed));
+} __packed;
 
 /*
  * tx ring initialization control block for chip.
@@ -1283,7 +1283,7 @@ struct wqicb {
 	__le16 rid;
 	__le64 addr;
 	__le64 cnsmr_idx_addr;
-} __attribute((packed));
+} __packed;
 
 /*
  * rx ring initialization control block for chip.
@@ -1317,7 +1317,7 @@ struct cqicb {
 	__le64 sbq_addr;
 	__le16 sbq_buf_size;
 	__le16 sbq_len;		/* entry count */
-} __attribute((packed));
+} __packed;
 
 struct ricb {
 	u8 base_cq;
@@ -1335,7 +1335,7 @@ struct ricb {
 	u8 hash_cq_id[1024];
 	__le32 ipv6_hash_key[10];
 	__le32 ipv4_hash_key[4];
-} __attribute((packed));
+} __packed;
 
 /* SOFTWARE/DRIVER DATA STRUCTURES. */
 
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index c088740..1f83404 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -38,7 +38,7 @@ struct efx_loopback_payload {
 	struct udphdr udp;
 	__be16 iteration;
 	const char msg[64];
-} __attribute__ ((packed));
+} __packed;
 
 /* Loopback test source MAC address */
 static const unsigned char payload_source[ETH_ALEN] = {
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 084eff2..61891a6 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2161,21 +2161,21 @@ struct sky2_tx_le {
 	__le16	length;	/* also vlan tag or checksum start */
 	u8	ctrl;
 	u8	opcode;
-} __attribute((packed));
+} __packed;
 
 struct sky2_rx_le {
 	__le32	addr;
 	__le16	length;
 	u8	ctrl;
 	u8	opcode;
-} __attribute((packed));
+} __packed;
 
 struct sky2_status_le {
 	__le32	status;	/* also checksum */
 	__le16	length;	/* also vlan tag */
 	u8	css;
 	u8	opcode;
-} __attribute((packed));
+} __packed;
 
 struct tx_ring_info {
 	struct sk_buff	*skb;
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index cff98d0..67e3b71 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -334,7 +334,7 @@ struct txd_desc {
 	u32 va_lo;
 	u32 va_hi;
 	struct pbl pbl[0];	/* Fragments */
-} __attribute__ ((packed));
+} __packed;
 
 /* Register region size */
 #define BDX_REGS_SIZE	  0x1000
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index c0e7000..9609626 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -262,13 +262,13 @@ struct de_srom_media_block {
 	u16			csr13;
 	u16			csr14;
 	u16			csr15;
-} __attribute__((packed));
+} __packed;
 
 struct de_srom_info_leaf {
 	u16			default_media;
 	u8			n_blocks;
 	u8			unused;
-} __attribute__((packed));
+} __packed;
 
 struct de_desc {
 	__le32			opts1;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 22bde49..2e50077 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -255,7 +255,7 @@ struct typhoon_shared {
 	struct rx_free			rxBuff[RXFREE_ENTRIES]	__3xp_aligned;
 	u32				zeroWord;
 	struct tx_desc			txHi[TXHI_ENTRIES];
-} __attribute__ ((packed));
+} __packed;
 
 struct rxbuff_ent {
 	struct sk_buff *skb;
diff --git a/drivers/net/typhoon.h b/drivers/net/typhoon.h
index 673fd51..88187fc 100644
--- a/drivers/net/typhoon.h
+++ b/drivers/net/typhoon.h
@@ -77,7 +77,7 @@ struct typhoon_indexes {
 	volatile __le32 cmdCleared;
 	volatile __le32 respReady;
 	volatile __le32 rxHiReady;
-} __attribute__ ((packed));
+} __packed;
 
 /* The host<->Typhoon interface
  * Our means of communicating where things are
@@ -125,7 +125,7 @@ struct typhoon_interface {
 	__le32 rxHiAddr;
 	__le32 rxHiAddrHi;
 	__le32 rxHiSize;
-} __attribute__ ((packed));
+} __packed;
 
 /* The Typhoon transmit/fragment descriptor
  *
@@ -187,7 +187,7 @@ struct tx_desc {
 #define TYPHOON_TX_PF_VLAN_MASK		cpu_to_le32(0x0ffff000)
 #define TYPHOON_TX_PF_INTERNAL		cpu_to_le32(0xf0000000)
 #define TYPHOON_TX_PF_VLAN_TAG_SHIFT	12
-} __attribute__ ((packed));
+} __packed;
 
 /* The TCP Segmentation offload option descriptor
  *
@@ -208,7 +208,7 @@ struct tcpopt_desc {
 	__le32 respAddrLo;
 	__le32 bytesTx;
 	__le32 status;
-} __attribute__ ((packed));
+} __packed;
 
 /* The IPSEC Offload descriptor
  *
@@ -227,7 +227,7 @@ struct ipsec_desc {
 	__le32 sa1;
 	__le32 sa2;
 	__le32 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /* The Typhoon receive descriptor (Updated by NIC)
  *
@@ -284,7 +284,7 @@ struct rx_desc {
 #define TYPHOON_RX_UNKNOWN_SA		cpu_to_le16(0x0100)
 #define TYPHOON_RX_ESP_FORMAT_ERR	cpu_to_le16(0x0200)
 	__be32 vlanTag;
-} __attribute__ ((packed));
+} __packed;
 
 /* The Typhoon free buffer descriptor, used to give a buffer to the NIC
  *
@@ -301,7 +301,7 @@ struct rx_free {
 	__le32 physAddrHi;
 	u32 virtAddr;
 	u32 virtAddrHi;
-} __attribute__ ((packed));
+} __packed;
 
 /* The Typhoon command descriptor, used for commands and responses
  *
@@ -347,7 +347,7 @@ struct cmd_desc {
 	__le16 parm1;
 	__le32 parm2;
 	__le32 parm3;
-} __attribute__ ((packed));
+} __packed;
 
 /* The Typhoon response descriptor, see command descriptor for details
  */
@@ -359,7 +359,7 @@ struct resp_desc {
 	__le16 parm1;
 	__le32 parm2;
 	__le32 parm3;
-} __attribute__ ((packed));
+} __packed;
 
 #define INIT_COMMAND_NO_RESPONSE(x, command)				\
 	do { struct cmd_desc *_ptr = (x);				\
@@ -427,7 +427,7 @@ struct stats_resp {
 #define TYPHOON_LINK_HALF_DUPLEX	cpu_to_le32(0x00000000)
 	__le32 unused2;
 	__le32 unused3;
-} __attribute__ ((packed));
+} __packed;
 
 /* TYPHOON_CMD_XCVR_SELECT xcvr values (resp.parm1)
  */
@@ -488,7 +488,7 @@ struct sa_descriptor {
 	u32 index;
 	u32 unused;
 	u32 unused2;
-} __attribute__ ((packed));
+} __packed;
 
 /* TYPHOON_CMD_SET_OFFLOAD_TASKS bits (cmd.parm2 (Tx) & cmd.parm3 (Rx))
  * This is all for IPv4.
@@ -518,14 +518,14 @@ struct typhoon_file_header {
 	__le32 numSections;
 	__le32 startAddr;
 	__le32 hmacDigest[5];
-} __attribute__ ((packed));
+} __packed;
 
 struct typhoon_section_header {
 	__le32 len;
 	u16 checksum;
 	u16 reserved;
 	__le32 startAddr;
-} __attribute__ ((packed));
+} __packed;
 
 /* The Typhoon Register offsets
  */
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index ef1fbeb..05a9558 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -106,7 +106,7 @@ struct ucc_geth {
 	u32 scar;		/* Statistics carry register */
 	u32 scam;		/* Statistics caryy mask register */
 	u8 res5[0x200 - 0x1c4];
-} __attribute__ ((packed));
+} __packed;
 
 /* UCC GETH TEMODR Register */
 #define TEMODER_TX_RMON_STATISTICS_ENABLE       0x0100	/* enable Tx statistics
@@ -420,11 +420,11 @@ struct ucc_geth {
 
 struct ucc_geth_thread_data_tx {
 	u8 res0[104];
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_thread_data_rx {
 	u8 res0[40];
-} __attribute__ ((packed));
+} __packed;
 
 /* Send Queue Queue-Descriptor */
 struct ucc_geth_send_queue_qd {
@@ -432,19 +432,19 @@ struct ucc_geth_send_queue_qd {
 	u8 res0[0x8];
 	u32 last_bd_completed_address;/* initialize to last entry in BD ring */
 	u8 res1[0x30];
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_send_queue_mem_region {
 	struct ucc_geth_send_queue_qd sqqd[NUM_TX_QUEUES];
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_thread_tx_pram {
 	u8 res0[64];
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_thread_rx_pram {
 	u8 res0[128];
-} __attribute__ ((packed));
+} __packed;
 
 #define THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING        64
 #define THREAD_RX_PRAM_ADDITIONAL_FOR_EXTENDED_FILTERING_8      64
@@ -484,7 +484,7 @@ struct ucc_geth_scheduler {
 				      /**< weight factor for queues   */
 	u32 minw;		/* temporary variable handled by QE */
 	u8 res1[0x70 - 0x64];
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_tx_firmware_statistics_pram {
 	u32 sicoltx;		/* single collision */
@@ -506,7 +506,7 @@ struct ucc_geth_tx_firmware_statistics_pram {
 				   and 1518 octets */
 	u32 txpktsjumbo;	/* total packets (including bad) between 1024
 				   and MAXLength octets */
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_rx_firmware_statistics_pram {
 	u32 frrxfcser;		/* frames with crc error */
@@ -540,7 +540,7 @@ struct ucc_geth_rx_firmware_statistics_pram {
 				   replaced */
 	u32 insertvlan;		/* total frames that had their VLAN tag
 				   inserted */
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_rx_interrupt_coalescing_entry {
 	u32 interruptcoalescingmaxvalue;	/* interrupt coalescing max
@@ -548,23 +548,23 @@ struct ucc_geth_rx_interrupt_coalescing_entry {
 	u32 interruptcoalescingcounter;	/* interrupt coalescing counter,
 					   initialize to
 					   interruptcoalescingmaxvalue */
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_rx_interrupt_coalescing_table {
 	struct ucc_geth_rx_interrupt_coalescing_entry coalescingentry[NUM_RX_QUEUES];
 				       /**< interrupt coalescing entry */
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_rx_prefetched_bds {
 	struct qe_bd bd[NUM_BDS_IN_PREFETCHED_BDS];	/* prefetched bd */
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_rx_bd_queues_entry {
 	u32 bdbaseptr;		/* BD base pointer */
 	u32 bdptr;		/* BD pointer */
 	u32 externalbdbaseptr;	/* external BD base pointer */
 	u32 externalbdptr;	/* external BD pointer */
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_tx_global_pram {
 	u16 temoder;
@@ -580,13 +580,13 @@ struct ucc_geth_tx_global_pram {
 	u32 tqptr;		/* a base pointer to the Tx Queues Memory
 				   Region */
 	u8 res2[0x80 - 0x74];
-} __attribute__ ((packed));
+} __packed;
 
 /* structure representing Extended Filtering Global Parameters in PRAM */
 struct ucc_geth_exf_global_pram {
 	u32 l2pcdptr;		/* individual address filter, high */
 	u8 res0[0x10 - 0x04];
-} __attribute__ ((packed));
+} __packed;
 
 struct ucc_geth_rx_global_pram {
 	u32 remoder;		/* ethernet mode reg. */
@@ -620,7 +620,7 @@ struct ucc_geth_rx_global_pram {
 	u32 exfGlobalParam;	/* base address for extended filtering global
 				   parameters */
 	u8 res6[0x100 - 0xC4];	/* Initialize to zero */
-} __attribute__ ((packed));
+} __packed;
 
 #define GRACEFUL_STOP_ACKNOWLEDGE_RX            0x01
 
@@ -639,7 +639,7 @@ struct ucc_geth_init_pram {
 	u32 txglobal;		/* tx global */
 	u32 txthread[ENET_INIT_PARAM_MAX_ENTRIES_TX];	/* tx threads */
 	u8 res3[0x1];
-} __attribute__ ((packed));
+} __packed;
 
 #define ENET_INIT_PARAM_RGF_SHIFT               (32 - 4)
 #define ENET_INIT_PARAM_TGF_SHIFT               (32 - 8)
@@ -661,7 +661,7 @@ struct ucc_geth_82xx_enet_address {
 	u16 h;			/* address (MSB) */
 	u16 m;			/* address */
 	u16 l;			/* address (LSB) */
-} __attribute__ ((packed));
+} __packed;
 
 /* structure representing 82xx Address Filtering PRAM */
 struct ucc_geth_82xx_address_filtering_pram {
@@ -672,7 +672,7 @@ struct ucc_geth_82xx_address_filtering_pram {
 	struct ucc_geth_82xx_enet_address __iomem taddr;
 	struct ucc_geth_82xx_enet_address __iomem paddr[NUM_OF_PADDRS];
 	u8 res0[0x40 - 0x38];
-} __attribute__ ((packed));
+} __packed;
 
 /* GETH Tx firmware statistics structure, used when calling
    UCC_GETH_GetStatistics. */
@@ -696,7 +696,7 @@ struct ucc_geth_tx_firmware_statistics {
 				   and 1518 octets */
 	u32 txpktsjumbo;	/* total packets (including bad) between 1024
 				   and MAXLength octets */
-} __attribute__ ((packed));
+} __packed;
 
 /* GETH Rx firmware statistics structure, used when calling
    UCC_GETH_GetStatistics. */
@@ -732,7 +732,7 @@ struct ucc_geth_rx_firmware_statistics {
 				   replaced */
 	u32 insertvlan;		/* total frames that had their VLAN tag
 				   inserted */
-} __attribute__ ((packed));
+} __packed;
 
 /* GETH hardware statistics structure, used when calling
    UCC_GETH_GetStatistics. */
@@ -781,7 +781,7 @@ struct ucc_geth_hardware_statistics {
 	u32 rbca;		/* Total number of frames received successfully
 				   that had destination address equal to the
 				   broadcast address */
-} __attribute__ ((packed));
+} __packed;
 
 /* UCC GETH Tx errors returned via TxConf callback */
 #define TX_ERRORS_DEF      0x0200
diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 1f802e9..7e797ed 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -179,7 +179,7 @@ struct ax88172_int_data {
 	__le16 res2;
 	u8 status;
 	__le16 res3;
-} __attribute__ ((packed));
+} __packed;
 
 static int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			    u16 size, void *data)
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 0a3c41f..c8570b0 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -211,7 +211,7 @@ struct hso_serial_state_notification {
 	u16 wIndex;
 	u16 wLength;
 	u16 UART_state_bitmap;
-} __attribute__((packed));
+} __packed;
 
 struct hso_tiocmget {
 	struct mutex mutex;
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index d6078b8..2b7b39c 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -207,7 +207,7 @@ struct kaweth_ethernet_configuration
 	__le16 segment_size;
 	__u16 max_multicast_filters;
 	__u8 reserved3;
-} __attribute__ ((packed));
+} __packed;
 
 /****************************************************************
  *     kaweth_device
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index 961a8ed..ba72a72 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -64,13 +64,13 @@ struct nc_header {		// packed:
 	// all else is optional, and must start with:
 	// __le16	vendorId;	// from usb-if
 	// __le16	productId;
-} __attribute__((__packed__));
+} __packed;
 
 #define	PAD_BYTE	((unsigned char)0xAC)
 
 struct nc_trailer {
 	__le16	packet_id;
-} __attribute__((__packed__));
+} __packed;
 
 // packets may use FLAG_FRAMING_NC and optional pad
 #define FRAMED_SIZE(mtu) (sizeof (struct nc_header) \
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index f1942d6..ee85c8b 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -165,7 +165,7 @@ struct lsi_umts {
 	u8 gw_addr_len; /* NW-supplied GW address len */
 	u8 gw_addr[16]; /* NW-supplied GW address (bigendian) */
 	u8 reserved[8];
-} __attribute__ ((packed));
+} __packed;
 
 #define SIERRA_NET_LSI_COMMON_LEN      4
 #define SIERRA_NET_LSI_UMTS_LEN        (sizeof(struct lsi_umts))
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index c381911..f7b33ae 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -193,7 +193,7 @@ struct rx_desc {
 	__le32 pa_low;		/* Low 32 bit PCI address */
 	__le16 pa_high;		/* Next 16 bit PCI address (48 total) */
 	__le16 size;		/* bits 0--14 - frame size, bit 15 - enable int. */
-} __attribute__ ((__packed__));
+} __packed;
 
 /*
  *	Transmit descriptor
@@ -208,7 +208,7 @@ struct tdesc1 {
 	__le16 vlan;
 	u8 TCR;
 	u8 cmd;			/* bits 0--1 - TCPLS, bits 4--7 - CMDZ */
-} __attribute__ ((__packed__));
+} __packed;
 
 enum {
 	TD_QUEUE = cpu_to_le16(0x8000)
@@ -218,7 +218,7 @@ struct td_buf {
 	__le32 pa_low;
 	__le16 pa_high;
 	__le16 size;		/* bits 0--13 - size, bit 15 - queue */
-} __attribute__ ((__packed__));
+} __packed;
 
 struct tx_desc {
 	struct tdesc0 tdesc0;
@@ -1096,7 +1096,7 @@ struct mac_regs {
 
 	volatile __le16 PatternCRC[8];	/* 0xB0 */
 	volatile __le32 ByteMask[4][4];	/* 0xC0 */
-} __attribute__ ((__packed__));
+} __packed;
 
 
 enum hw_mib {
@@ -1216,7 +1216,7 @@ struct arp_packet {
 	u8 ar_sip[4];
 	u8 ar_tha[ETH_ALEN];
 	u8 ar_tip[4];
-} __attribute__ ((__packed__));
+} __packed;
 
 struct _magic_packet {
 	u8 dest_mac[6];
@@ -1224,7 +1224,7 @@ struct _magic_packet {
 	__be16 type;
 	u8 MAC[16][6];
 	u8 password[6];
-} __attribute__ ((__packed__));
+} __packed;
 
 /*
  *	Store for chip context when saving and restoring status. Not
diff --git a/drivers/net/wan/hd64570.h b/drivers/net/wan/hd64570.h
index 3839662..e4f539a 100644
--- a/drivers/net/wan/hd64570.h
+++ b/drivers/net/wan/hd64570.h
@@ -153,7 +153,7 @@ typedef struct {
 	u16 len;		/* Data Length */
 	u8 stat;		/* Status */
 	u8 unused;		/* pads to 2-byte boundary */
-}__attribute__ ((packed)) pkt_desc;
+}__packed pkt_desc;
 
 
 /* Packet Descriptor Status bits */
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index ee7083f..b38ffa1 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -36,7 +36,7 @@ struct hdlc_header {
 	u8 address;
 	u8 control;
 	__be16 protocol;
-}__attribute__ ((packed));
+}__packed;
 
 
 struct cisco_packet {
@@ -45,7 +45,7 @@ struct cisco_packet {
 	__be32 par2;
 	__be16 rel;		/* reliability */
 	__be32 time;
-}__attribute__ ((packed));
+}__packed;
 #define	CISCO_PACKET_LEN	18
 #define	CISCO_BIG_PACKET_LEN	20
 
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 0e52993..0edb535 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -112,7 +112,7 @@ typedef struct {
 	unsigned de:	1;
 	unsigned ea2:	1;
 #endif
-}__attribute__ ((packed)) fr_hdr;
+}__packed fr_hdr;
 
 
 typedef struct pvc_device_struct {
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index e155938..f4125da 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -330,7 +330,7 @@ struct _dlci_stat
 {
 	short dlci;
 	char  flags;
-} __attribute__((packed));
+} __packed;
 
 struct _frad_stat 
 {
diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index d86e8f3..2f725d0 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -848,7 +848,7 @@ struct i2400m_cmd_enter_power_save {
 	struct i2400m_l3l4_hdr hdr;
 	struct i2400m_tlv_hdr tlv;
 	__le32 val;
-} __attribute__((packed));
+} __packed;
 
 
 /*
diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 3f283bf..e9b34b0 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -651,7 +651,7 @@ static int i2400m_download_chunk(struct i2400m *i2400m, const void *chunk,
 	struct {
 		struct i2400m_bootrom_header cmd;
 		u8 cmd_payload[chunk_len];
-	} __attribute__((packed)) *buf;
+	} __packed *buf;
 	struct i2400m_bootrom_header ack;
 
 	d_fnstart(5, dev, "(i2400m %p chunk %p __chunk_len %zu addr 0x%08lx "
@@ -794,7 +794,7 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
 	struct {
 		struct i2400m_bootrom_header cmd;
 		u8 cmd_pl[0];
-	} __attribute__((packed)) *cmd_buf;
+	} __packed *cmd_buf;
 	size_t signature_block_offset, signature_block_size;
 
 	d_fnstart(3, dev, "offset %zu\n", offset);
@@ -1029,7 +1029,7 @@ int i2400m_read_mac_addr(struct i2400m *i2400m)
 	struct {
 		struct i2400m_bootrom_header ack;
 		u8 ack_pl[16];
-	} __attribute__((packed)) ack_buf;
+	} __packed ack_buf;
 
 	d_fnstart(5, dev, "(i2400m %p)\n", i2400m);
 	cmd = i2400m->bm_cmd_buf;
@@ -1115,7 +1115,7 @@ int i2400m_dnload_init_signed(struct i2400m *i2400m,
 	struct {
 		struct i2400m_bootrom_header cmd;
 		struct i2400m_bcf_hdr cmd_pl;
-	} __attribute__((packed)) *cmd_buf;
+	} __packed *cmd_buf;
 	struct i2400m_bootrom_header ack;
 
 	d_fnstart(5, dev, "(i2400m %p bcf_hdr %p)\n", i2400m, bcf_hdr);
diff --git a/drivers/net/wimax/i2400m/op-rfkill.c b/drivers/net/wimax/i2400m/op-rfkill.c
index 035e4cf..9e02b90 100644
--- a/drivers/net/wimax/i2400m/op-rfkill.c
+++ b/drivers/net/wimax/i2400m/op-rfkill.c
@@ -91,7 +91,7 @@ int i2400m_op_rfkill_sw_toggle(struct wimax_dev *wimax_dev,
 	struct {
 		struct i2400m_l3l4_hdr hdr;
 		struct i2400m_tlv_rf_operation sw_rf;
-	} __attribute__((packed)) *cmd;
+	} __packed *cmd;
 	char strerr[32];
 
 	d_fnstart(4, dev, "(wimax_dev %p state %d)\n", wimax_dev, state);
diff --git a/drivers/net/wireless/adm8211.h b/drivers/net/wireless/adm8211.h
index b07e4d3..bbc10b1 100644
--- a/drivers/net/wireless/adm8211.h
+++ b/drivers/net/wireless/adm8211.h
@@ -80,7 +80,7 @@ struct adm8211_csr {
 	__le32 FEMR;		/* 0x104 */
 	__le32 FPSR;		/* 0x108 */
 	__le32 FFER;		/* 0x10C */
-} __attribute__ ((packed));
+} __packed;
 
 /* CSR0 - PAR (PCI Address Register) */
 #define ADM8211_PAR_MWIE	(1 << 24)
@@ -484,7 +484,7 @@ struct adm8211_tx_hdr {
 	u8 entry_control;	// huh??
 	u16 reserved_1;
 	u32 reserved_2;
-} __attribute__ ((packed));
+} __packed;
 
 
 #define RX_COPY_BREAK 128
@@ -531,7 +531,7 @@ struct adm8211_eeprom {
 	u8	lnags_threshold[14];	/* 0x70 */
 	__le16	checksum;		/* 0x7E */
 	u8	cis_data[0];		/* 0x80, 384 bytes */
-} __attribute__ ((packed));
+} __packed;
 
 struct adm8211_priv {
 	struct pci_dev *pdev;
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 3b7ab20..6b605df 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -506,20 +506,20 @@ struct WepKeyRid {
 	u8 mac[ETH_ALEN];
 	__le16 klen;
 	u8 key[16];
-} __attribute__ ((packed));
+} __packed;
 
 /* These structures are from the Aironet's PC4500 Developers Manual */
 typedef struct Ssid Ssid;
 struct Ssid {
 	__le16 len;
 	u8 ssid[32];
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct SsidRid SsidRid;
 struct SsidRid {
 	__le16 len;
 	Ssid ssids[3];
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct ModulationRid ModulationRid;
 struct ModulationRid {
@@ -528,7 +528,7 @@ struct ModulationRid {
 #define MOD_DEFAULT cpu_to_le16(0)
 #define MOD_CCK cpu_to_le16(1)
 #define MOD_MOK cpu_to_le16(2)
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct ConfigRid ConfigRid;
 struct ConfigRid {
@@ -652,7 +652,7 @@ struct ConfigRid {
 #define MAGIC_STAY_IN_CAM (1<<10)
 	u8 magicControl;
 	__le16 autoWake;
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct StatusRid StatusRid;
 struct StatusRid {
@@ -711,20 +711,20 @@ struct StatusRid {
 #define STAT_LEAPFAILED 91
 #define STAT_LEAPTIMEDOUT 92
 #define STAT_LEAPCOMPLETE 93
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct StatsRid StatsRid;
 struct StatsRid {
 	__le16 len;
 	__le16 spacer;
 	__le32 vals[100];
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct APListRid APListRid;
 struct APListRid {
 	__le16 len;
 	u8 ap[4][ETH_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct CapabilityRid CapabilityRid;
 struct CapabilityRid {
@@ -754,7 +754,7 @@ struct CapabilityRid {
 	__le16 bootBlockVer;
 	__le16 requiredHard;
 	__le16 extSoftCap;
-} __attribute__ ((packed));
+} __packed;
 
 /* Only present on firmware >= 5.30.17 */
 typedef struct BSSListRidExtra BSSListRidExtra;
@@ -762,7 +762,7 @@ struct BSSListRidExtra {
   __le16 unknown[4];
   u8 fixed[12]; /* WLAN management frame */
   u8 iep[624];
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct BSSListRid BSSListRid;
 struct BSSListRid {
@@ -796,7 +796,7 @@ struct BSSListRid {
 
   /* Only present on firmware >= 5.30.17 */
   BSSListRidExtra extra;
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct {
   BSSListRid bss;
@@ -807,13 +807,13 @@ typedef struct tdsRssiEntry tdsRssiEntry;
 struct tdsRssiEntry {
   u8 rssipct;
   u8 rssidBm;
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct tdsRssiRid tdsRssiRid;
 struct tdsRssiRid {
   u16 len;
   tdsRssiEntry x[256];
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct MICRid MICRid;
 struct MICRid {
@@ -823,7 +823,7 @@ struct MICRid {
 	u8  multicast[16];
 	__le16 unicastValid;
 	u8  unicast[16];
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct MICBuffer MICBuffer;
 struct MICBuffer {
@@ -841,7 +841,7 @@ struct MICBuffer {
 	} u;
 	__be32 mic;
 	__be32 seq;
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct {
 	u8 da[ETH_ALEN];
@@ -996,7 +996,7 @@ struct rx_hdr {
 	u8 rate;
 	u8 freq;
 	__le16 tmp[4];
-} __attribute__ ((packed));
+} __packed;
 
 typedef struct {
 	unsigned int  ctl: 15;
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 8a2d4af..429b281 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -305,7 +305,7 @@ struct dfu_status {
 	unsigned char poll_timeout[3];
 	unsigned char state;
 	unsigned char string;
-} __attribute__((packed));
+} __packed;
 
 static inline int at76_is_intersil(enum board_type board)
 {
diff --git a/drivers/net/wireless/at76c50x-usb.h b/drivers/net/wireless/at76c50x-usb.h
index 1ec5ccf..972ea0f 100644
--- a/drivers/net/wireless/at76c50x-usb.h
+++ b/drivers/net/wireless/at76c50x-usb.h
@@ -99,7 +99,7 @@ struct hwcfg_r505 {
 	u8 reserved2[14];
 	u8 cr15_values[14];
 	u8 reserved3[3];
-} __attribute__((packed));
+} __packed;
 
 struct hwcfg_rfmd {
 	u8 cr20_values[14];
@@ -111,7 +111,7 @@ struct hwcfg_rfmd {
 	u8 low_power_values[14];
 	u8 normal_power_values[14];
 	u8 reserved1[3];
-} __attribute__((packed));
+} __packed;
 
 struct hwcfg_intersil {
 	u8 mac_addr[ETH_ALEN];
@@ -120,7 +120,7 @@ struct hwcfg_intersil {
 	u8 pidvid[4];
 	u8 regulatory_domain;
 	u8 reserved[1];
-} __attribute__((packed));
+} __packed;
 
 union at76_hwcfg {
 	struct hwcfg_intersil i;
@@ -149,14 +149,14 @@ struct at76_card_config {
 	u8 ssid_len;
 	u8 short_preamble;
 	__le16 beacon_period;
-} __attribute__((packed));
+} __packed;
 
 struct at76_command {
 	u8 cmd;
 	u8 reserved;
 	__le16 size;
 	u8 data[0];
-} __attribute__((packed));
+} __packed;
 
 /* Length of Atmel-specific Rx header before 802.11 frame */
 #define AT76_RX_HDRLEN offsetof(struct at76_rx_buffer, packet)
@@ -171,7 +171,7 @@ struct at76_rx_buffer {
 	u8 noise_level;
 	__le32 rx_time;
 	u8 packet[IEEE80211_MAX_FRAG_THRESHOLD];
-} __attribute__((packed));
+} __packed;
 
 /* Length of Atmel-specific Tx header before 802.11 frame */
 #define AT76_TX_HDRLEN offsetof(struct at76_tx_buffer, packet)
@@ -182,7 +182,7 @@ struct at76_tx_buffer {
 	u8 padding;
 	u8 reserved[4];
 	u8 packet[IEEE80211_MAX_FRAG_THRESHOLD];
-} __attribute__((packed));
+} __packed;
 
 /* defines for scan_type below */
 #define SCAN_TYPE_ACTIVE	0
@@ -198,7 +198,7 @@ struct at76_req_scan {
 	__le16 max_channel_time;
 	u8 essid_size;
 	u8 international_scan;
-} __attribute__((packed));
+} __packed;
 
 struct at76_req_ibss {
 	u8 bssid[ETH_ALEN];
@@ -207,7 +207,7 @@ struct at76_req_ibss {
 	u8 channel;
 	u8 essid_size;
 	u8 reserved[3];
-} __attribute__((packed));
+} __packed;
 
 struct at76_req_join {
 	u8 bssid[ETH_ALEN];
@@ -217,7 +217,7 @@ struct at76_req_join {
 	__le16 timeout;
 	u8 essid_size;
 	u8 reserved;
-} __attribute__((packed));
+} __packed;
 
 struct set_mib_buffer {
 	u8 type;
@@ -229,7 +229,7 @@ struct set_mib_buffer {
 		__le16 word;
 		u8 addr[ETH_ALEN];
 	} data;
-} __attribute__((packed));
+} __packed;
 
 struct mib_local {
 	u16 reserved0;
@@ -241,14 +241,14 @@ struct mib_local {
 	u16 reserved2;
 	u8 preamble_type;
 	u16 reserved3;
-} __attribute__((packed));
+} __packed;
 
 struct mib_mac_addr {
 	u8 mac_addr[ETH_ALEN];
 	u8 res[2];		/* ??? */
 	u8 group_addr[4][ETH_ALEN];
 	u8 group_addr_status[4];
-} __attribute__((packed));
+} __packed;
 
 struct mib_mac {
 	__le32 max_tx_msdu_lifetime;
@@ -269,7 +269,7 @@ struct mib_mac {
 	u8 desired_bssid[ETH_ALEN];
 	u8 desired_bsstype;	/* ad-hoc or infrastructure */
 	u8 reserved2;
-} __attribute__((packed));
+} __packed;
 
 struct mib_mac_mgmt {
 	__le16 beacon_period;
@@ -292,7 +292,7 @@ struct mib_mac_mgmt {
 	u8 multi_domain_capability_enabled;
 	u8 country_string[3];
 	u8 reserved[3];
-} __attribute__((packed));
+} __packed;
 
 struct mib_mac_wep {
 	u8 privacy_invoked;	/* 0 disable encr., 1 enable encr */
@@ -303,7 +303,7 @@ struct mib_mac_wep {
 	__le32 wep_excluded_count;
 	u8 wep_default_keyvalue[WEP_KEYS][WEP_LARGE_KEY_LEN];
 	u8 encryption_level;	/* 1 for 40bit, 2 for 104bit encryption */
-} __attribute__((packed));
+} __packed;
 
 struct mib_phy {
 	__le32 ed_threshold;
@@ -320,19 +320,19 @@ struct mib_phy {
 	u8 current_cca_mode;
 	u8 phy_type;
 	u8 current_reg_domain;
-} __attribute__((packed));
+} __packed;
 
 struct mib_fw_version {
 	u8 major;
 	u8 minor;
 	u8 patch;
 	u8 build;
-} __attribute__((packed));
+} __packed;
 
 struct mib_mdomain {
 	u8 tx_powerlevel[14];
 	u8 channel_list[14];	/* 0 for invalid channels */
-} __attribute__((packed));
+} __packed;
 
 struct at76_fw_header {
 	__le32 crc;		/* CRC32 of the whole image */
@@ -346,7 +346,7 @@ struct at76_fw_header {
 	__le32 int_fw_len;	/* internal firmware image length */
 	__le32 ext_fw_offset;	/* external firmware image offset */
 	__le32 ext_fw_len;	/* external firmware image length */
-} __attribute__((packed));
+} __packed;
 
 /* a description of a regulatory domain and the allowed channels */
 struct reg_domain {
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index 3a003e6..8674a99 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -530,7 +530,7 @@ struct b43_fw_header {
 	/* Size of the data. For ucode and PCM this is in bytes.
 	 * For IV this is number-of-ivs. */
 	__be32 size;
-} __attribute__((__packed__));
+} __packed;
 
 /* Initial Value file format */
 #define B43_IV_OFFSET_MASK	0x7FFF
@@ -540,8 +540,8 @@ struct b43_iv {
 	union {
 		__be16 d16;
 		__be32 d32;
-	} data __attribute__((__packed__));
-} __attribute__((__packed__));
+	} data __packed;
+} __packed;
 
 
 /* Data structures for DMA transmission, per 80211 core. */
diff --git a/drivers/net/wireless/b43/dma.h b/drivers/net/wireless/b43/dma.h
index dc91944..a01c210 100644
--- a/drivers/net/wireless/b43/dma.h
+++ b/drivers/net/wireless/b43/dma.h
@@ -67,7 +67,7 @@
 struct b43_dmadesc32 {
 	__le32 control;
 	__le32 address;
-} __attribute__ ((__packed__));
+} __packed;
 #define B43_DMA32_DCTL_BYTECNT		0x00001FFF
 #define B43_DMA32_DCTL_ADDREXT_MASK		0x00030000
 #define B43_DMA32_DCTL_ADDREXT_SHIFT	16
@@ -140,7 +140,7 @@ struct b43_dmadesc64 {
 	__le32 control1;
 	__le32 address_low;
 	__le32 address_high;
-} __attribute__ ((__packed__));
+} __packed;
 #define B43_DMA64_DCTL0_DTABLEEND		0x10000000
 #define B43_DMA64_DCTL0_IRQ			0x20000000
 #define B43_DMA64_DCTL0_FRAMEEND		0x40000000
@@ -153,8 +153,8 @@ struct b43_dmadesc_generic {
 	union {
 		struct b43_dmadesc32 dma32;
 		struct b43_dmadesc64 dma64;
-	} __attribute__ ((__packed__));
-} __attribute__ ((__packed__));
+	} __packed;
+} __packed;
 
 /* Misc DMA constants */
 #define B43_DMA_RINGMEMSIZE		PAGE_SIZE
diff --git a/drivers/net/wireless/b43/xmit.h b/drivers/net/wireless/b43/xmit.h
index d23ff9f..d4cf9b3 100644
--- a/drivers/net/wireless/b43/xmit.h
+++ b/drivers/net/wireless/b43/xmit.h
@@ -10,8 +10,8 @@
 		union {				\
 			__le32 data;		\
 			__u8 raw[size];		\
-		} __attribute__((__packed__));	\
-	} __attribute__((__packed__))
+		} __packed;	\
+	} __packed
 
 /* struct b43_plcp_hdr4 */
 _b43_declare_plcp_hdr(4);
@@ -57,7 +57,7 @@ struct b43_txhdr {
 			__u8 rts_frame[16];		/* The RTS frame (if used) */
 			PAD_BYTES(2);
 			struct b43_plcp_hdr6 plcp;	/* Main PLCP header */
-		} new_format __attribute__ ((__packed__));
+		} new_format __packed;
 
 		/* The old r351 format. */
 		struct {
@@ -68,10 +68,10 @@ struct b43_txhdr {
 			__u8 rts_frame[16];		/* The RTS frame (if used) */
 			PAD_BYTES(2);
 			struct b43_plcp_hdr6 plcp;	/* Main PLCP header */
-		} old_format __attribute__ ((__packed__));
+		} old_format __packed;
 
-	} __attribute__ ((__packed__));
-} __attribute__ ((__packed__));
+	} __packed;
+} __packed;
 
 /* MAC TX control */
 #define B43_TXH_MAC_USEFBR		0x10000000 /* Use fallback rate for this AMPDU */
@@ -218,20 +218,20 @@ struct b43_rxhdr_fw4 {
 		struct {
 			__u8 jssi;	/* PHY RX Status 1: JSSI */
 			__u8 sig_qual;	/* PHY RX Status 1: Signal Quality */
-		} __attribute__ ((__packed__));
+		} __packed;
 
 		/* RSSI for N-PHYs */
 		struct {
 			__s8 power0;	/* PHY RX Status 1: Power 0 */
 			__s8 power1;	/* PHY RX Status 1: Power 1 */
-		} __attribute__ ((__packed__));
-	} __attribute__ ((__packed__));
+		} __packed;
+	} __packed;
 	__le16 phy_status2;	/* PHY RX Status 2 */
 	__le16 phy_status3;	/* PHY RX Status 3 */
 	__le32 mac_status;	/* MAC RX status */
 	__le16 mac_time;
 	__le16 channel;
-} __attribute__ ((__packed__));
+} __packed;
 
 /* PHY RX Status 0 */
 #define B43_RX_PHYST0_GAINCTL		0x4000 /* Gain Control */
diff --git a/drivers/net/wireless/b43legacy/b43legacy.h b/drivers/net/wireless/b43legacy/b43legacy.h
index 89fe2f9..c81b2f5 100644
--- a/drivers/net/wireless/b43legacy/b43legacy.h
+++ b/drivers/net/wireless/b43legacy/b43legacy.h
@@ -372,7 +372,7 @@ struct b43legacy_fw_header {
 	/* Size of the data. For ucode and PCM this is in bytes.
 	 * For IV this is number-of-ivs. */
 	__be32 size;
-} __attribute__((__packed__));
+} __packed;
 
 /* Initial Value file format */
 #define B43legacy_IV_OFFSET_MASK	0x7FFF
@@ -382,8 +382,8 @@ struct b43legacy_iv {
 	union {
 		__be16 d16;
 		__be32 d32;
-	} data __attribute__((__packed__));
-} __attribute__((__packed__));
+	} data __packed;
+} __packed;
 
 #define B43legacy_PHYMODE(phytype)	(1 << (phytype))
 #define B43legacy_PHYMODE_B		B43legacy_PHYMODE	\
diff --git a/drivers/net/wireless/b43legacy/dma.h b/drivers/net/wireless/b43legacy/dma.h
index f968104..f89c342 100644
--- a/drivers/net/wireless/b43legacy/dma.h
+++ b/drivers/net/wireless/b43legacy/dma.h
@@ -72,7 +72,7 @@
 struct b43legacy_dmadesc32 {
 	__le32 control;
 	__le32 address;
-} __attribute__((__packed__));
+} __packed;
 #define B43legacy_DMA32_DCTL_BYTECNT		0x00001FFF
 #define B43legacy_DMA32_DCTL_ADDREXT_MASK	0x00030000
 #define B43legacy_DMA32_DCTL_ADDREXT_SHIFT	16
@@ -147,7 +147,7 @@ struct b43legacy_dmadesc64 {
 	__le32 control1;
 	__le32 address_low;
 	__le32 address_high;
-} __attribute__((__packed__));
+} __packed;
 #define B43legacy_DMA64_DCTL0_DTABLEEND		0x10000000
 #define B43legacy_DMA64_DCTL0_IRQ		0x20000000
 #define B43legacy_DMA64_DCTL0_FRAMEEND		0x40000000
@@ -162,8 +162,8 @@ struct b43legacy_dmadesc_generic {
 	union {
 		struct b43legacy_dmadesc32 dma32;
 		struct b43legacy_dmadesc64 dma64;
-	} __attribute__((__packed__));
-} __attribute__((__packed__));
+	} __packed;
+} __packed;
 
 
 /* Misc DMA constants */
diff --git a/drivers/net/wireless/b43legacy/xmit.h b/drivers/net/wireless/b43legacy/xmit.h
index 9163308..289db00 100644
--- a/drivers/net/wireless/b43legacy/xmit.h
+++ b/drivers/net/wireless/b43legacy/xmit.h
@@ -9,8 +9,8 @@
 		union {				\
 			__le32 data;		\
 			__u8 raw[size];		\
-		} __attribute__((__packed__));	\
-	} __attribute__((__packed__))
+		} __packed;	\
+	} __packed
 
 /* struct b43legacy_plcp_hdr4 */
 _b43legacy_declare_plcp_hdr(4);
@@ -39,7 +39,7 @@ struct b43legacy_txhdr_fw3 {
 	struct b43legacy_plcp_hdr6 rts_plcp;	/* RTS PLCP */
 	__u8 rts_frame[18];			/* The RTS frame (if used) */
 	struct b43legacy_plcp_hdr6 plcp;
-} __attribute__((__packed__));
+} __packed;
 
 /* MAC TX control */
 #define B43legacy_TX4_MAC_KEYIDX	0x0FF00000 /* Security key index */
@@ -123,7 +123,7 @@ struct b43legacy_hwtxstatus {
 	__le16 seq;
 	u8 phy_stat;
 	PAD_BYTES(1);
-} __attribute__((__packed__));
+} __packed;
 
 
 /* Receive header for v3 firmware. */
@@ -138,7 +138,7 @@ struct b43legacy_rxhdr_fw3 {
 	__le16 mac_status;	/* MAC RX status */
 	__le16 mac_time;
 	__le16 channel;
-} __attribute__((__packed__));
+} __packed;
 
 
 /* PHY RX Status 0 */
diff --git a/drivers/net/wireless/hostap/hostap_80211.h b/drivers/net/wireless/hostap/hostap_80211.h
index 7f9d8d9..ed98ce7 100644
--- a/drivers/net/wireless/hostap/hostap_80211.h
+++ b/drivers/net/wireless/hostap/hostap_80211.h
@@ -19,35 +19,35 @@ struct hostap_ieee80211_mgmt {
 			__le16 status_code;
 			/* possibly followed by Challenge text */
 			u8 variable[0];
-		} __attribute__ ((packed)) auth;
+		} __packed auth;
 		struct {
 			__le16 reason_code;
-		} __attribute__ ((packed)) deauth;
+		} __packed deauth;
 		struct {
 			__le16 capab_info;
 			__le16 listen_interval;
 			/* followed by SSID and Supported rates */
 			u8 variable[0];
-		} __attribute__ ((packed)) assoc_req;
+		} __packed assoc_req;
 		struct {
 			__le16 capab_info;
 			__le16 status_code;
 			__le16 aid;
 			/* followed by Supported rates */
 			u8 variable[0];
-		} __attribute__ ((packed)) assoc_resp, reassoc_resp;
+		} __packed assoc_resp, reassoc_resp;
 		struct {
 			__le16 capab_info;
 			__le16 listen_interval;
 			u8 current_ap[6];
 			/* followed by SSID and Supported rates */
 			u8 variable[0];
-		} __attribute__ ((packed)) reassoc_req;
+		} __packed reassoc_req;
 		struct {
 			__le16 reason_code;
-		} __attribute__ ((packed)) disassoc;
+		} __packed disassoc;
 		struct {
-		} __attribute__ ((packed)) probe_req;
+		} __packed probe_req;
 		struct {
 			u8 timestamp[8];
 			__le16 beacon_int;
@@ -55,9 +55,9 @@ struct hostap_ieee80211_mgmt {
 			/* followed by some of SSID, Supported rates,
 			 * FH Params, DS Params, CF Params, IBSS Params, TIM */
 			u8 variable[0];
-		} __attribute__ ((packed)) beacon, probe_resp;
+		} __packed beacon, probe_resp;
 	} u;
-} __attribute__ ((packed));
+} __packed;
 
 
 #define IEEE80211_MGMT_HDR_LEN 24
diff --git a/drivers/net/wireless/hostap/hostap_common.h b/drivers/net/wireless/hostap/hostap_common.h
index 90b64b0..4230102 100644
--- a/drivers/net/wireless/hostap/hostap_common.h
+++ b/drivers/net/wireless/hostap/hostap_common.h
@@ -179,7 +179,7 @@ struct hfa384x_comp_ident
 	__le16 variant;
 	__le16 major;
 	__le16 minor;
-} __attribute__ ((packed));
+} __packed;
 
 #define HFA384X_COMP_ID_PRI 0x15
 #define HFA384X_COMP_ID_STA 0x1f
@@ -192,14 +192,14 @@ struct hfa384x_sup_range
 	__le16 variant;
 	__le16 bottom;
 	__le16 top;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct hfa384x_build_id
 {
 	__le16 pri_seq;
 	__le16 sec_seq;
-} __attribute__ ((packed));
+} __packed;
 
 /* FD01 - Download Buffer */
 struct hfa384x_rid_download_buffer
@@ -207,14 +207,14 @@ struct hfa384x_rid_download_buffer
 	__le16 page;
 	__le16 offset;
 	__le16 length;
-} __attribute__ ((packed));
+} __packed;
 
 /* BSS connection quality (RID FD43 range, RID FD51 dBm-normalized) */
 struct hfa384x_comms_quality {
 	__le16 comm_qual; /* 0 .. 92 */
 	__le16 signal_level; /* 27 .. 154 */
 	__le16 noise_level; /* 27 .. 154 */
-} __attribute__ ((packed));
+} __packed;
 
 
 /* netdevice private ioctls (used, e.g., with iwpriv from user space) */
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index 3d23891..c02f866 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -31,14 +31,14 @@ struct linux_wlan_ng_val {
 	u32 did;
 	u16 status, len;
 	u32 data;
-} __attribute__ ((packed));
+} __packed;
 
 struct linux_wlan_ng_prism_hdr {
 	u32 msgcode, msglen;
 	char devname[16];
 	struct linux_wlan_ng_val hosttime, mactime, channel, rssi, sq, signal,
 		noise, rate, istx, frmlen;
-} __attribute__ ((packed));
+} __packed;
 
 struct linux_wlan_ng_cap_hdr {
 	__be32 version;
@@ -55,7 +55,7 @@ struct linux_wlan_ng_cap_hdr {
 	__be32 ssi_noise;
 	__be32 preamble;
 	__be32 encoding;
-} __attribute__ ((packed));
+} __packed;
 
 struct hostap_radiotap_rx {
 	struct ieee80211_radiotap_header hdr;
@@ -66,7 +66,7 @@ struct hostap_radiotap_rx {
 	__le16 chan_flags;
 	s8 dbm_antsignal;
 	s8 dbm_antnoise;
-} __attribute__ ((packed));
+} __packed;
 
 #define LWNG_CAP_DID_BASE   (4 | (1 << 6)) /* section 4, group 1 */
 #define LWNG_CAPHDR_VERSION 0x80211001
@@ -97,7 +97,7 @@ struct hfa384x_rx_frame {
 	__be16 len;
 
 	/* followed by frame data; max 2304 bytes */
-} __attribute__ ((packed));
+} __packed;
 
 
 struct hfa384x_tx_frame {
@@ -126,14 +126,14 @@ struct hfa384x_tx_frame {
 	__be16 len;
 
 	/* followed by frame data; max 2304 bytes */
-} __attribute__ ((packed));
+} __packed;
 
 
 struct hfa384x_rid_hdr
 {
 	__le16 len;
 	__le16 rid;
-} __attribute__ ((packed));
+} __packed;
 
 
 /* Macro for converting signal levels (range 27 .. 154) to wireless ext
@@ -145,24 +145,24 @@ struct hfa384x_rid_hdr
 struct hfa384x_scan_request {
 	__le16 channel_list;
 	__le16 txrate; /* HFA384X_RATES_* */
-} __attribute__ ((packed));
+} __packed;
 
 struct hfa384x_hostscan_request {
 	__le16 channel_list;
 	__le16 txrate;
 	__le16 target_ssid_len;
 	u8 target_ssid[32];
-} __attribute__ ((packed));
+} __packed;
 
 struct hfa384x_join_request {
 	u8 bssid[6];
 	__le16 channel;
-} __attribute__ ((packed));
+} __packed;
 
 struct hfa384x_info_frame {
 	__le16 len;
 	__le16 type;
-} __attribute__ ((packed));
+} __packed;
 
 struct hfa384x_comm_tallies {
 	__le16 tx_unicast_frames;
@@ -186,7 +186,7 @@ struct hfa384x_comm_tallies {
 	__le16 rx_discards_wep_undecryptable;
 	__le16 rx_message_in_msg_fragments;
 	__le16 rx_message_in_bad_msg_fragments;
-} __attribute__ ((packed));
+} __packed;
 
 struct hfa384x_comm_tallies32 {
 	__le32 tx_unicast_frames;
@@ -210,7 +210,7 @@ struct hfa384x_comm_tallies32 {
 	__le32 rx_discards_wep_undecryptable;
 	__le32 rx_message_in_msg_fragments;
 	__le32 rx_message_in_bad_msg_fragments;
-} __attribute__ ((packed));
+} __packed;
 
 struct hfa384x_scan_result_hdr {
 	__le16 reserved;
@@ -219,7 +219,7 @@ struct hfa384x_scan_result_hdr {
 #define HFA384X_SCAN_HOST_INITIATED 1
 #define HFA384X_SCAN_FIRMWARE_INITIATED 2
 #define HFA384X_SCAN_INQUIRY_FROM_HOST 3
-} __attribute__ ((packed));
+} __packed;
 
 #define HFA384X_SCAN_MAX_RESULTS 32
 
@@ -234,7 +234,7 @@ struct hfa384x_scan_result {
 	u8 ssid[32];
 	u8 sup_rates[10];
 	__le16 rate;
-} __attribute__ ((packed));
+} __packed;
 
 struct hfa384x_hostscan_result {
 	__le16 chid;
@@ -248,7 +248,7 @@ struct hfa384x_hostscan_result {
 	u8 sup_rates[10];
 	__le16 rate;
 	__le16 atim;
-} __attribute__ ((packed));
+} __packed;
 
 struct comm_tallies_sums {
 	unsigned int tx_unicast_frames;
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 0bd4dfa..4264fc0 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -5233,7 +5233,7 @@ struct security_info_params {
 	u8 auth_mode;
 	u8 replay_counters_number;
 	u8 unicast_using_group;
-} __attribute__ ((packed));
+} __packed;
 
 static int ipw2100_set_security_information(struct ipw2100_priv *priv,
 					    int auth_mode,
@@ -8475,7 +8475,7 @@ struct ipw2100_fw_header {
 	short mode;
 	unsigned int fw_size;
 	unsigned int uc_size;
-} __attribute__ ((packed));
+} __packed;
 
 static int ipw2100_mod_firmware_load(struct ipw2100_fw *fw)
 {
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.h b/drivers/net/wireless/ipw2x00/ipw2100.h
index 1eab0d6..838002b 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.h
+++ b/drivers/net/wireless/ipw2x00/ipw2100.h
@@ -164,7 +164,7 @@ struct bd_status {
 		} fields;
 		u8 field;
 	} info;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw2100_bd {
 	u32 host_addr;
@@ -174,7 +174,7 @@ struct ipw2100_bd {
 	 * 1st TBD) */
 	u8 num_fragments;
 	u8 reserved[6];
-} __attribute__ ((packed));
+} __packed;
 
 #define IPW_BD_QUEUE_LENGTH(n) (1<<n)
 #define IPW_BD_ALIGNMENT(L)    (L*sizeof(struct ipw2100_bd))
@@ -232,7 +232,7 @@ struct ipw2100_status {
 #define IPW_STATUS_FLAG_WEP_ENCRYPTED	(1<<1)
 #define IPW_STATUS_FLAG_CRC_ERROR       (1<<2)
 	u8 rssi;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw2100_status_queue {
 	/* driver (virtual) pointer to queue */
@@ -293,7 +293,7 @@ struct ipw2100_cmd_header {
 	u32 reserved1[3];
 	u32 *ordinal1_ptr;
 	u32 *ordinal2_ptr;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw2100_data_header {
 	u32 host_command_reg;
@@ -307,7 +307,7 @@ struct ipw2100_data_header {
 	u8 src_addr[ETH_ALEN];
 	u8 dst_addr[ETH_ALEN];
 	u16 fragment_size;
-} __attribute__ ((packed));
+} __packed;
 
 /* Host command data structure */
 struct host_command {
@@ -316,7 +316,7 @@ struct host_command {
 	u32 host_command_sequence;	// UNIQUE COMMAND NUMBER (ID)
 	u32 host_command_length;	// LENGTH
 	u32 host_command_parameters[HOST_COMMAND_PARAMS_REG_LEN];	// COMMAND PARAMETERS
-} __attribute__ ((packed));
+} __packed;
 
 typedef enum {
 	POWER_ON_RESET,
@@ -382,7 +382,7 @@ struct ipw2100_notification {
 	u32 hnhdr_size;		/* size in bytes of data
 				   or number of entries, if table.
 				   Does NOT include header */
-} __attribute__ ((packed));
+} __packed;
 
 #define MAX_KEY_SIZE	16
 #define	MAX_KEYS	8
@@ -814,7 +814,7 @@ struct ipw2100_rx {
 		struct ipw2100_notification notification;
 		struct ipw2100_cmd_header command;
 	} rx_data;
-} __attribute__ ((packed));
+} __packed;
 
 /* Bit 0-7 are for 802.11b tx rates - .  Bit 5-7 are reserved */
 #define TX_RATE_1_MBIT              0x0001
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.h b/drivers/net/wireless/ipw2x00/ipw2200.h
index bf0eeb2..d7d049c 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.h
+++ b/drivers/net/wireless/ipw2x00/ipw2200.h
@@ -388,7 +388,7 @@ struct clx2_queue {
 	dma_addr_t dma_addr;		/**< physical addr for BD's */
 	int low_mark;		       /**< low watermark, resume queue if free space more than this */
 	int high_mark;		       /**< high watermark, stop queue if free space less than this */
-} __attribute__ ((packed)); /* XXX */
+} __packed; /* XXX */
 
 struct machdr32 {
 	__le16 frame_ctl;
@@ -399,7 +399,7 @@ struct machdr32 {
 	__le16 seq_ctrl;		// more endians!
 	u8 addr4[MACADRR_BYTE_LEN];
 	__le16 qos_ctrl;
-} __attribute__ ((packed));
+} __packed;
 
 struct machdr30 {
 	__le16 frame_ctl;
@@ -409,7 +409,7 @@ struct machdr30 {
 	u8 addr3[MACADRR_BYTE_LEN];
 	__le16 seq_ctrl;		// more endians!
 	u8 addr4[MACADRR_BYTE_LEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct machdr26 {
 	__le16 frame_ctl;
@@ -419,7 +419,7 @@ struct machdr26 {
 	u8 addr3[MACADRR_BYTE_LEN];
 	__le16 seq_ctrl;		// more endians!
 	__le16 qos_ctrl;
-} __attribute__ ((packed));
+} __packed;
 
 struct machdr24 {
 	__le16 frame_ctl;
@@ -428,20 +428,20 @@ struct machdr24 {
 	u8 addr2[MACADRR_BYTE_LEN];
 	u8 addr3[MACADRR_BYTE_LEN];
 	__le16 seq_ctrl;		// more endians!
-} __attribute__ ((packed));
+} __packed;
 
 // TX TFD with 32 byte MAC Header
 struct tx_tfd_32 {
 	struct machdr32 mchdr;	// 32
 	__le32 uivplaceholder[2];	// 8
-} __attribute__ ((packed));
+} __packed;
 
 // TX TFD with 30 byte MAC Header
 struct tx_tfd_30 {
 	struct machdr30 mchdr;	// 30
 	u8 reserved[2];		// 2
 	__le32 uivplaceholder[2];	// 8
-} __attribute__ ((packed));
+} __packed;
 
 // tx tfd with 26 byte mac header
 struct tx_tfd_26 {
@@ -449,14 +449,14 @@ struct tx_tfd_26 {
 	u8 reserved1[2];	// 2
 	__le32 uivplaceholder[2];	// 8
 	u8 reserved2[4];	// 4
-} __attribute__ ((packed));
+} __packed;
 
 // tx tfd with 24 byte mac header
 struct tx_tfd_24 {
 	struct machdr24 mchdr;	// 24
 	__le32 uivplaceholder[2];	// 8
 	u8 reserved[8];		// 8
-} __attribute__ ((packed));
+} __packed;
 
 #define DCT_WEP_KEY_FIELD_LENGTH 16
 
@@ -465,7 +465,7 @@ struct tfd_command {
 	u8 length;
 	__le16 reserved;
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct tfd_data {
 	/* Header */
@@ -504,14 +504,14 @@ struct tfd_data {
 	__le32 num_chunks;
 	__le32 chunk_ptr[NUM_TFD_CHUNKS];
 	__le16 chunk_len[NUM_TFD_CHUNKS];
-} __attribute__ ((packed));
+} __packed;
 
 struct txrx_control_flags {
 	u8 message_type;
 	u8 rx_seq_num;
 	u8 control_bits;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 #define  TFD_SIZE                           128
 #define  TFD_CMD_IMMEDIATE_PAYLOAD_LENGTH   (TFD_SIZE - sizeof(struct txrx_control_flags))
@@ -523,7 +523,7 @@ struct tfd_frame {
 		struct tfd_command cmd;
 		u8 raw[TFD_CMD_IMMEDIATE_PAYLOAD_LENGTH];
 	} u;
-} __attribute__ ((packed));
+} __packed;
 
 typedef void destructor_func(const void *);
 
@@ -559,7 +559,7 @@ struct rate_histogram {
 		__le32 b[SUP_RATE_11B_MAX_NUM_CHANNELS];
 		__le32 g[SUP_RATE_11G_MAX_NUM_CHANNELS];
 	} failed;
-} __attribute__ ((packed));
+} __packed;
 
 /* statistics command response */
 struct ipw_cmd_stats {
@@ -586,13 +586,13 @@ struct ipw_cmd_stats {
 	__le16 rx_autodetec_no_ofdm;
 	__le16 rx_autodetec_no_barker;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct notif_channel_result {
 	u8 channel_num;
 	struct ipw_cmd_stats stats;
 	u8 uReserved;
-} __attribute__ ((packed));
+} __packed;
 
 #define SCAN_COMPLETED_STATUS_COMPLETE  1
 #define SCAN_COMPLETED_STATUS_ABORTED   2
@@ -602,24 +602,24 @@ struct notif_scan_complete {
 	u8 num_channels;
 	u8 status;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct notif_frag_length {
 	__le16 frag_length;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct notif_beacon_state {
 	__le32 state;
 	__le32 number;
-} __attribute__ ((packed));
+} __packed;
 
 struct notif_tgi_tx_key {
 	u8 key_state;
 	u8 security_type;
 	u8 station_index;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 #define SILENCE_OVER_THRESH (1)
 #define SILENCE_UNDER_THRESH (2)
@@ -631,25 +631,25 @@ struct notif_link_deterioration {
 	struct rate_histogram histogram;
 	u8 silence_notification_type;	/* SILENCE_OVER/UNDER_THRESH */
 	__le16 silence_count;
-} __attribute__ ((packed));
+} __packed;
 
 struct notif_association {
 	u8 state;
-} __attribute__ ((packed));
+} __packed;
 
 struct notif_authenticate {
 	u8 state;
 	struct machdr24 addr;
 	__le16 status;
-} __attribute__ ((packed));
+} __packed;
 
 struct notif_calibration {
 	u8 data[104];
-} __attribute__ ((packed));
+} __packed;
 
 struct notif_noise {
 	__le32 value;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_rx_notification {
 	u8 reserved[8];
@@ -669,7 +669,7 @@ struct ipw_rx_notification {
 		struct notif_noise noise;
 		u8 raw[0];
 	} u;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_rx_frame {
 	__le32 reserved1;
@@ -692,14 +692,14 @@ struct ipw_rx_frame {
 	u8 rtscts_seen;		// 0x1 RTS seen ; 0x2 CTS seen
 	__le16 length;
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_rx_header {
 	u8 message_type;
 	u8 rx_seq_num;
 	u8 control_bits;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_rx_packet {
 	struct ipw_rx_header header;
@@ -707,7 +707,7 @@ struct ipw_rx_packet {
 		struct ipw_rx_frame frame;
 		struct ipw_rx_notification notification;
 	} u;
-} __attribute__ ((packed));
+} __packed;
 
 #define IPW_RX_NOTIFICATION_SIZE sizeof(struct ipw_rx_header) + 12
 #define IPW_RX_FRAME_SIZE        (unsigned int)(sizeof(struct ipw_rx_header) + \
@@ -717,7 +717,7 @@ struct ipw_rx_mem_buffer {
 	dma_addr_t dma_addr;
 	struct sk_buff *skb;
 	struct list_head list;
-};				/* Not transferred over network, so not  __attribute__ ((packed)) */
+};				/* Not transferred over network, so not  __packed */
 
 struct ipw_rx_queue {
 	struct ipw_rx_mem_buffer pool[RX_QUEUE_SIZE + RX_FREE_BUFFERS];
@@ -730,7 +730,7 @@ struct ipw_rx_queue {
 	struct list_head rx_free;	/* Own an SKBs */
 	struct list_head rx_used;	/* No SKB allocated */
 	spinlock_t lock;
-};				/* Not transferred over network, so not  __attribute__ ((packed)) */
+};				/* Not transferred over network, so not  __packed */
 
 struct alive_command_responce {
 	u8 alive_command;
@@ -745,21 +745,21 @@ struct alive_command_responce {
 	__le16 reserved4;
 	u8 time_stamp[5];	/* month, day, year, hours, minutes */
 	u8 ucode_valid;
-} __attribute__ ((packed));
+} __packed;
 
 #define IPW_MAX_RATES 12
 
 struct ipw_rates {
 	u8 num_rates;
 	u8 rates[IPW_MAX_RATES];
-} __attribute__ ((packed));
+} __packed;
 
 struct command_block {
 	unsigned int control;
 	u32 source_addr;
 	u32 dest_addr;
 	unsigned int status;
-} __attribute__ ((packed));
+} __packed;
 
 #define CB_NUMBER_OF_ELEMENTS_SMALL 64
 struct fw_image_desc {
@@ -792,7 +792,7 @@ struct ipw_sys_config {
 	u8 accept_all_mgmt_frames;
 	u8 pass_noise_stats_to_host;
 	u8 reserved3;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_multicast_addr {
 	u8 num_of_multicast_addresses;
@@ -801,7 +801,7 @@ struct ipw_multicast_addr {
 	u8 mac2[6];
 	u8 mac3[6];
 	u8 mac4[6];
-} __attribute__ ((packed));
+} __packed;
 
 #define DCW_WEP_KEY_INDEX_MASK		0x03	/* bits [0:1] */
 #define DCW_WEP_KEY_SEC_TYPE_MASK	0x30	/* bits [4:5] */
@@ -822,7 +822,7 @@ struct ipw_wep_key {
 	u8 key_index;
 	u8 key_size;
 	u8 key[16];
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_tgi_tx_key {
 	u8 key_id;
@@ -831,7 +831,7 @@ struct ipw_tgi_tx_key {
 	u8 flags;
 	u8 key[16];
 	__le32 tx_counter[2];
-} __attribute__ ((packed));
+} __packed;
 
 #define IPW_SCAN_CHANNELS 54
 
@@ -840,7 +840,7 @@ struct ipw_scan_request {
 	__le16 dwell_time;
 	u8 channels_list[IPW_SCAN_CHANNELS];
 	u8 channels_reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	IPW_SCAN_PASSIVE_TILL_FIRST_BEACON_SCAN = 0,
@@ -857,7 +857,7 @@ struct ipw_scan_request_ext {
 	u8 scan_type[IPW_SCAN_CHANNELS / 2];
 	u8 reserved;
 	__le16 dwell_time[IPW_SCAN_TYPES];
-} __attribute__ ((packed));
+} __packed;
 
 static inline u8 ipw_get_scan_type(struct ipw_scan_request_ext *scan, u8 index)
 {
@@ -902,7 +902,7 @@ struct ipw_associate {
 	u8 smr;
 	u8 reserved1;
 	__le16 reserved2;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_supported_rates {
 	u8 ieee_mode;
@@ -910,36 +910,36 @@ struct ipw_supported_rates {
 	u8 purpose;
 	u8 reserved;
 	u8 supported_rates[IPW_MAX_RATES];
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_rts_threshold {
 	__le16 rts_threshold;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_frag_threshold {
 	__le16 frag_threshold;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_retry_limit {
 	u8 short_retry_limit;
 	u8 long_retry_limit;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_dino_config {
 	__le32 dino_config_addr;
 	__le16 dino_config_size;
 	u8 dino_response;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_aironet_info {
 	u8 id;
 	u8 length;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_rx_key {
 	u8 station_index;
@@ -950,25 +950,25 @@ struct ipw_rx_key {
 	u8 station_address[6];
 	u8 key_index;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_country_channel_info {
 	u8 first_channel;
 	u8 no_channels;
 	s8 max_tx_power;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_country_info {
 	u8 id;
 	u8 length;
 	u8 country_str[3];
 	struct ipw_country_channel_info groups[7];
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_channel_tx_power {
 	u8 channel_number;
 	s8 tx_power;
-} __attribute__ ((packed));
+} __packed;
 
 #define SCAN_ASSOCIATED_INTERVAL (HZ)
 #define SCAN_INTERVAL (HZ / 10)
@@ -979,18 +979,18 @@ struct ipw_tx_power {
 	u8 num_channels;
 	u8 ieee_mode;
 	struct ipw_channel_tx_power channels_tx_power[MAX_A_CHANNELS];
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_rsn_capabilities {
 	u8 id;
 	u8 length;
 	__le16 version;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_sensitivity_calib {
 	__le16 beacon_rssi_raw;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * Host command structure.
@@ -1019,7 +1019,7 @@ struct ipw_cmd {	 /* XXX */
    * nParams=(len+3)/4+status_len
    */
 	u32 param[0];
-} __attribute__ ((packed));
+} __packed;
 
 #define STATUS_HCMD_ACTIVE      (1<<0)	/**< host command in progress */
 
@@ -1114,7 +1114,7 @@ struct ipw_event {	 /* XXX */
 	u32 event;
 	u32 time;
 	u32 data;
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_fw_error {	 /* XXX */
 	unsigned long jiffies;
@@ -1125,7 +1125,7 @@ struct ipw_fw_error {	 /* XXX */
 	struct ipw_error_elem *elem;
 	struct ipw_event *log;
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 #ifdef CONFIG_IPW2200_PROMISCUOUS
 
@@ -1170,7 +1170,7 @@ struct ipw_rt_hdr {
 	s8 rt_dbmnoise;
 	u8 rt_antenna;	/* antenna number */
 	u8 payload[0];  /* payload... */
-} __attribute__ ((packed));
+} __packed;
 #endif
 
 struct ipw_priv {
@@ -1957,7 +1957,7 @@ enum {
 struct ipw_fixed_rate {
 	__le16 tx_rates;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 #define IPW_INDIRECT_ADDR_MASK (~0x3ul)
 
@@ -1966,14 +1966,14 @@ struct host_cmd {
 	u8 len;
 	u16 reserved;
 	u32 *param;
-} __attribute__ ((packed));	/* XXX */
+} __packed;	/* XXX */
 
 struct cmdlog_host_cmd {
 	u8 cmd;
 	u8 len;
 	__le16 reserved;
 	char param[124];
-} __attribute__ ((packed));
+} __packed;
 
 struct ipw_cmd_log {
 	unsigned long jiffies;
diff --git a/drivers/net/wireless/ipw2x00/libipw.h b/drivers/net/wireless/ipw2x00/libipw.h
index 284b0e4..4736861 100644
--- a/drivers/net/wireless/ipw2x00/libipw.h
+++ b/drivers/net/wireless/ipw2x00/libipw.h
@@ -154,7 +154,7 @@ struct libipw_snap_hdr {
 	u8 ctrl;		/* always 0x03 */
 	u8 oui[P80211_OUI_LEN];	/* organizational universal id */
 
-} __attribute__ ((packed));
+} __packed;
 
 #define SNAP_SIZE sizeof(struct libipw_snap_hdr)
 
@@ -323,7 +323,7 @@ struct libipw_security {
 	u8 keys[WEP_KEYS][SCM_KEY_LEN];
 	u8 level;
 	u16 flags;
-} __attribute__ ((packed));
+} __packed;
 
 /*
 
@@ -347,7 +347,7 @@ struct libipw_hdr_1addr {
 	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_hdr_2addr {
 	__le16 frame_ctl;
@@ -355,7 +355,7 @@ struct libipw_hdr_2addr {
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_hdr_3addr {
 	__le16 frame_ctl;
@@ -365,7 +365,7 @@ struct libipw_hdr_3addr {
 	u8 addr3[ETH_ALEN];
 	__le16 seq_ctl;
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_hdr_4addr {
 	__le16 frame_ctl;
@@ -376,7 +376,7 @@ struct libipw_hdr_4addr {
 	__le16 seq_ctl;
 	u8 addr4[ETH_ALEN];
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_hdr_3addrqos {
 	__le16 frame_ctl;
@@ -387,13 +387,13 @@ struct libipw_hdr_3addrqos {
 	__le16 seq_ctl;
 	u8 payload[0];
 	__le16 qos_ctl;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_info_element {
 	u8 id;
 	u8 len;
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * These are the data types that can make up management packets
@@ -406,7 +406,7 @@ struct libipw_info_element {
 	u16 listen_interval;
 	struct {
 		u16 association_id:14, reserved:2;
-	} __attribute__ ((packed));
+	} __packed;
 	u32 time_stamp[2];
 	u16 reason;
 	u16 status;
@@ -419,7 +419,7 @@ struct libipw_auth {
 	__le16 status;
 	/* challenge */
 	struct libipw_info_element info_element[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_channel_switch {
 	u8 id;
@@ -427,7 +427,7 @@ struct libipw_channel_switch {
 	u8 mode;
 	u8 channel;
 	u8 count;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_action {
 	struct libipw_hdr_3addr header;
@@ -441,12 +441,12 @@ struct libipw_action {
 		struct libipw_channel_switch channel_switch;
 
 	} format;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_disassoc {
 	struct libipw_hdr_3addr header;
 	__le16 reason;
-} __attribute__ ((packed));
+} __packed;
 
 /* Alias deauth for disassoc */
 #define libipw_deauth libipw_disassoc
@@ -455,7 +455,7 @@ struct libipw_probe_request {
 	struct libipw_hdr_3addr header;
 	/* SSID, supported rates */
 	struct libipw_info_element info_element[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_probe_response {
 	struct libipw_hdr_3addr header;
@@ -465,7 +465,7 @@ struct libipw_probe_response {
 	/* SSID, supported rates, FH params, DS params,
 	 * CF params, IBSS params, TIM (if beacon), RSN */
 	struct libipw_info_element info_element[0];
-} __attribute__ ((packed));
+} __packed;
 
 /* Alias beacon for probe_response */
 #define libipw_beacon libipw_probe_response
@@ -476,7 +476,7 @@ struct libipw_assoc_request {
 	__le16 listen_interval;
 	/* SSID, supported rates, RSN */
 	struct libipw_info_element info_element[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_reassoc_request {
 	struct libipw_hdr_3addr header;
@@ -484,7 +484,7 @@ struct libipw_reassoc_request {
 	__le16 listen_interval;
 	u8 current_ap[ETH_ALEN];
 	struct libipw_info_element info_element[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_assoc_response {
 	struct libipw_hdr_3addr header;
@@ -493,7 +493,7 @@ struct libipw_assoc_response {
 	__le16 aid;
 	/* supported rates */
 	struct libipw_info_element info_element[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_txb {
 	u8 nr_frags;
@@ -555,19 +555,19 @@ struct libipw_qos_information_element {
 	u8 qui_subtype;
 	u8 version;
 	u8 ac_info;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_qos_ac_parameter {
 	u8 aci_aifsn;
 	u8 ecw_min_max;
 	__le16 tx_op_limit;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_qos_parameter_info {
 	struct libipw_qos_information_element info_element;
 	u8 reserved;
 	struct libipw_qos_ac_parameter ac_params_record[QOS_QUEUE_NUM];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_qos_parameters {
 	__le16 cw_min[QOS_QUEUE_NUM];
@@ -575,7 +575,7 @@ struct libipw_qos_parameters {
 	u8 aifs[QOS_QUEUE_NUM];
 	u8 flag[QOS_QUEUE_NUM];
 	__le16 tx_op_limit[QOS_QUEUE_NUM];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_qos_data {
 	struct libipw_qos_parameters parameters;
@@ -588,7 +588,7 @@ struct libipw_qos_data {
 struct libipw_tim_parameters {
 	u8 tim_count;
 	u8 tim_period;
-} __attribute__ ((packed));
+} __packed;
 
 /*******************************************************/
 
@@ -606,7 +606,7 @@ struct libipw_basic_report {
 	__le64 start_time;
 	__le16 duration;
 	u8 map;
-} __attribute__ ((packed));
+} __packed;
 
 enum {				/* libipw_measurement_request.mode */
 	/* Bit 0 is reserved */
@@ -627,7 +627,7 @@ struct libipw_measurement_params {
 	u8 channel;
 	__le64 start_time;
 	__le16 duration;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_measurement_request {
 	struct libipw_info_element ie;
@@ -635,7 +635,7 @@ struct libipw_measurement_request {
 	u8 mode;
 	u8 type;
 	struct libipw_measurement_params params[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_measurement_report {
 	struct libipw_info_element ie;
@@ -645,17 +645,17 @@ struct libipw_measurement_report {
 	union {
 		struct libipw_basic_report basic[0];
 	} u;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_tpc_report {
 	u8 transmit_power;
 	u8 link_margin;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_channel_map {
 	u8 channel;
 	u8 map;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_ibss_dfs {
 	struct libipw_info_element ie;
@@ -668,14 +668,14 @@ struct libipw_csa {
 	u8 mode;
 	u8 channel;
 	u8 count;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_quiet {
 	u8 count;
 	u8 period;
 	u8 duration;
 	u8 offset;
-} __attribute__ ((packed));
+} __packed;
 
 struct libipw_network {
 	/* These entries are used to identify a unique network */
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-fh.h b/drivers/net/wireless/iwlwifi/iwl-3945-fh.h
index 042f6bc..2c9ed2b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-fh.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-fh.h
@@ -175,13 +175,13 @@
 struct iwl3945_tfd_tb {
 	__le32 addr;
 	__le32 len;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl3945_tfd {
 	__le32 control_flags;
 	struct iwl3945_tfd_tb tbs[4];
 	u8 __pad[28];
-} __attribute__ ((packed));
+} __packed;
 
 
 #endif /* __iwl_3945_fh_h__ */
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-hw.h b/drivers/net/wireless/iwlwifi/iwl-3945-hw.h
index 91bcb4e..7c731a7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-hw.h
@@ -96,7 +96,7 @@ struct iwl3945_eeprom_txpower_sample {
 	u8 gain_index;		/* index into power (gain) setup table ... */
 	s8 power;		/* ... for this pwr level for this chnl group */
 	u16 v_det;		/* PA output voltage */
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Mappings of Tx power levels -> nominal radio/DSP gain table indexes.
@@ -117,7 +117,7 @@ struct iwl3945_eeprom_txpower_group {
 	u8 group_channel;	/* "representative" channel # in this band */
 	s16 temperature;	/* h/w temperature at factory calib this band
 				 * (signed) */
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Temperature-based Tx-power compensation data, not band-specific.
@@ -131,7 +131,7 @@ struct iwl3945_eeprom_temperature_corr {
 	u32 Tc;
 	u32 Td;
 	u32 Te;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * EEPROM map
@@ -215,7 +215,7 @@ struct iwl3945_eeprom {
 /* abs.ofs: 512 */
 	struct iwl3945_eeprom_temperature_corr corrections;  /* abs.ofs: 832 */
 	u8 reserved16[172];	/* fill out to full 1024 byte block */
-} __attribute__ ((packed));
+} __packed;
 
 #define IWL3945_EEPROM_IMG_SIZE 1024
 
@@ -274,7 +274,7 @@ static inline int iwl3945_hw_valid_rtc_data_addr(u32 addr)
  * and &iwl3945_shared.rx_read_ptr[0] is provided to FH_RCSR_RPTR_ADDR(0) */
 struct iwl3945_shared {
 	__le32 tx_base_ptr[8];
-} __attribute__ ((packed));
+} __packed;
 
 static inline u8 iwl3945_hw_get_rate(__le16 rate_n_flags)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-hw.h b/drivers/net/wireless/iwlwifi/iwl-4965-hw.h
index cd4b61a..9166794 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-hw.h
@@ -787,6 +787,6 @@ enum {
 struct iwl4965_scd_bc_tbl {
 	__le16 tfd_offset[TFD_QUEUE_BC_SIZE];
 	u8 pad[1024 - (TFD_QUEUE_BC_SIZE) * sizeof(__le16)];
-} __attribute__ ((packed));
+} __packed;
 
 #endif /* !__iwl_4965_hw_h__ */
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-hw.h b/drivers/net/wireless/iwlwifi/iwl-agn-hw.h
index f9a3fbb..a52b82c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-hw.h
@@ -112,7 +112,7 @@
  */
 struct iwlagn_scd_bc_tbl {
 	__le16 tfd_offset[TFD_QUEUE_BC_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 
 #endif /* __iwl_agn_hw_h__ */
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/wireless/iwlwifi/iwl-commands.h
index 9aab020..73d2d59 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -227,7 +227,7 @@ struct iwl_cmd_header {
 
 	/* command or response/notification data follows immediately */
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 
 /**
@@ -247,7 +247,7 @@ struct iwl_cmd_header {
 struct iwl3945_tx_power {
 	u8 tx_gain;		/* gain for analog radio */
 	u8 dsp_atten;		/* gain for DSP */
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * struct iwl3945_power_per_rate
@@ -258,7 +258,7 @@ struct iwl3945_power_per_rate {
 	u8 rate;		/* plcp */
 	struct iwl3945_tx_power tpc;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * iwlagn rate_n_flags bit fields
@@ -389,7 +389,7 @@ union iwl4965_tx_power_dual_stream {
  */
 struct tx_power_dual_stream {
 	__le32 dw;
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * struct iwl4965_tx_power_db
@@ -398,7 +398,7 @@ struct tx_power_dual_stream {
  */
 struct iwl4965_tx_power_db {
 	struct tx_power_dual_stream power_tbl[POWER_TABLE_NUM_ENTRIES];
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * Command REPLY_TX_POWER_DBM_CMD = 0x98
@@ -412,7 +412,7 @@ struct iwl5000_tx_power_dbm_cmd {
 	u8 flags;
 	s8 srv_chan_lmt; /*in half-dBm (e.g. 30 = 15 dBm) */
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * Command TX_ANT_CONFIGURATION_CMD = 0x98
@@ -422,7 +422,7 @@ struct iwl5000_tx_power_dbm_cmd {
  */
 struct iwl_tx_ant_config_cmd {
 	__le32 valid;
-} __attribute__ ((packed));
+} __packed;
 
 /******************************************************************************
  * (0a)
@@ -478,7 +478,7 @@ struct iwl_init_alive_resp {
 	__le32 therm_r4[2];	/* signed */
 	__le32 tx_atten[5][2];	/* signed MIMO gain comp, 5 freq groups,
 				 * 2 Tx chains */
-} __attribute__ ((packed));
+} __packed;
 
 
 /**
@@ -570,7 +570,7 @@ struct iwl_alive_resp {
 	__le32 error_event_table_ptr;	/* SRAM address for error log */
 	__le32 timestamp;
 	__le32 is_valid;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_ERROR = 0x2 (response only, not a command)
@@ -582,7 +582,7 @@ struct iwl_error_resp {
 	__le16 bad_cmd_seq_num;
 	__le32 error_info;
 	__le64 timestamp;
-} __attribute__ ((packed));
+} __packed;
 
 /******************************************************************************
  * (1)
@@ -718,7 +718,7 @@ struct iwl3945_rxon_cmd {
 	__le32 filter_flags;
 	__le16 channel;
 	__le16 reserved5;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl4965_rxon_cmd {
 	u8 node_addr[6];
@@ -738,7 +738,7 @@ struct iwl4965_rxon_cmd {
 	__le16 channel;
 	u8 ofdm_ht_single_stream_basic_rates;
 	u8 ofdm_ht_dual_stream_basic_rates;
-} __attribute__ ((packed));
+} __packed;
 
 /* 5000 HW just extend this command */
 struct iwl_rxon_cmd {
@@ -763,7 +763,7 @@ struct iwl_rxon_cmd {
 	u8 reserved5;
 	__le16 acquisition_data;
 	__le16 reserved6;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_RXON_ASSOC = 0x11 (command, has simple generic response)
@@ -774,7 +774,7 @@ struct iwl3945_rxon_assoc_cmd {
 	u8 ofdm_basic_rates;
 	u8 cck_basic_rates;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl4965_rxon_assoc_cmd {
 	__le32 flags;
@@ -785,7 +785,7 @@ struct iwl4965_rxon_assoc_cmd {
 	u8 ofdm_ht_dual_stream_basic_rates;
 	__le16 rx_chain_select_flags;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl5000_rxon_assoc_cmd {
 	__le32 flags;
@@ -800,7 +800,7 @@ struct iwl5000_rxon_assoc_cmd {
 	__le16 rx_chain_select_flags;
 	__le16 acquisition_data;
 	__le32 reserved3;
-} __attribute__ ((packed));
+} __packed;
 
 #define IWL_CONN_MAX_LISTEN_INTERVAL	10
 #define IWL_MAX_UCODE_BEACON_INTERVAL	4 /* 4096 */
@@ -816,7 +816,7 @@ struct iwl_rxon_time_cmd {
 	__le32 beacon_init_val;
 	__le16 listen_interval;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_CHANNEL_SWITCH = 0x72 (command, has simple generic response)
@@ -829,7 +829,7 @@ struct iwl3945_channel_switch_cmd {
 	__le32 rxon_filter_flags;
 	__le32 switch_time;
 	struct iwl3945_power_per_rate power[IWL_MAX_RATES];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl4965_channel_switch_cmd {
 	u8 band;
@@ -839,7 +839,7 @@ struct iwl4965_channel_switch_cmd {
 	__le32 rxon_filter_flags;
 	__le32 switch_time;
 	struct iwl4965_tx_power_db tx_power;
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * struct iwl5000_channel_switch_cmd
@@ -860,7 +860,7 @@ struct iwl5000_channel_switch_cmd {
 	__le32 rxon_filter_flags;
 	__le32 switch_time;
 	__le32 reserved[2][IWL_PWR_NUM_HT_OFDM_ENTRIES + IWL_PWR_CCK_ENTRIES];
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * struct iwl6000_channel_switch_cmd
@@ -881,7 +881,7 @@ struct iwl6000_channel_switch_cmd {
 	__le32 rxon_filter_flags;
 	__le32 switch_time;
 	__le32 reserved[3][IWL_PWR_NUM_HT_OFDM_ENTRIES + IWL_PWR_CCK_ENTRIES];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * CHANNEL_SWITCH_NOTIFICATION = 0x73 (notification only, not a command)
@@ -890,7 +890,7 @@ struct iwl_csa_notification {
 	__le16 band;
 	__le16 channel;
 	__le32 status;		/* 0 - OK, 1 - fail */
-} __attribute__ ((packed));
+} __packed;
 
 /******************************************************************************
  * (2)
@@ -920,7 +920,7 @@ struct iwl_ac_qos {
 	u8 aifsn;
 	u8 reserved1;
 	__le16 edca_txop;
-} __attribute__ ((packed));
+} __packed;
 
 /* QoS flags defines */
 #define QOS_PARAM_FLG_UPDATE_EDCA_MSK	cpu_to_le32(0x01)
@@ -939,7 +939,7 @@ struct iwl_ac_qos {
 struct iwl_qosparam_cmd {
 	__le32 qos_flags;
 	struct iwl_ac_qos ac[AC_NUM];
-} __attribute__ ((packed));
+} __packed;
 
 /******************************************************************************
  * (3)
@@ -1015,7 +1015,7 @@ struct iwl4965_keyinfo {
 	u8 key_offset;
 	u8 reserved2;
 	u8 key[16];		/* 16-byte unicast decryption key */
-} __attribute__ ((packed));
+} __packed;
 
 /* 5000 */
 struct iwl_keyinfo {
@@ -1029,7 +1029,7 @@ struct iwl_keyinfo {
 	__le64 tx_secur_seq_cnt;
 	__le64 hw_tkip_mic_rx_key;
 	__le64 hw_tkip_mic_tx_key;
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * struct sta_id_modify
@@ -1049,7 +1049,7 @@ struct sta_id_modify {
 	u8 sta_id;
 	u8 modify_mask;
 	__le16 reserved2;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_ADD_STA = 0x18 (command)
@@ -1103,7 +1103,7 @@ struct iwl3945_addsta_cmd {
 	/* Starting Sequence Number for added block-ack support.
 	 * Set modify_mask bit STA_MODIFY_ADDBA_TID_MSK to use this field. */
 	__le16 add_immediate_ba_ssn;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl4965_addsta_cmd {
 	u8 mode;		/* 1: modify existing, 0: add new station */
@@ -1140,7 +1140,7 @@ struct iwl4965_addsta_cmd {
 	__le16 sleep_tx_count;
 
 	__le16 reserved2;
-} __attribute__ ((packed));
+} __packed;
 
 /* 5000 */
 struct iwl_addsta_cmd {
@@ -1178,7 +1178,7 @@ struct iwl_addsta_cmd {
 	__le16 sleep_tx_count;
 
 	__le16 reserved2;
-} __attribute__ ((packed));
+} __packed;
 
 
 #define ADD_STA_SUCCESS_MSK		0x1
@@ -1190,7 +1190,7 @@ struct iwl_addsta_cmd {
  */
 struct iwl_add_sta_resp {
 	u8 status;	/* ADD_STA_* */
-} __attribute__ ((packed));
+} __packed;
 
 #define REM_STA_SUCCESS_MSK              0x1
 /*
@@ -1198,7 +1198,7 @@ struct iwl_add_sta_resp {
  */
 struct iwl_rem_sta_resp {
 	u8 status;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  *  REPLY_REM_STA = 0x19 (command)
@@ -1208,7 +1208,7 @@ struct iwl_rem_sta_cmd {
 	u8 reserved[3];
 	u8 addr[ETH_ALEN]; /* MAC addr of the first station */
 	u8 reserved2[2];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_WEP_KEY = 0x20
@@ -1220,7 +1220,7 @@ struct iwl_wep_key {
 	u8 key_size;
 	u8 reserved2[3];
 	u8 key[16];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_wep_cmd {
 	u8 num_keys;
@@ -1228,7 +1228,7 @@ struct iwl_wep_cmd {
 	u8 flags;
 	u8 reserved;
 	struct iwl_wep_key key[0];
-} __attribute__ ((packed));
+} __packed;
 
 #define WEP_KEY_WEP_TYPE 1
 #define WEP_KEYS_MAX 4
@@ -1282,7 +1282,7 @@ struct iwl3945_rx_frame_stats {
 	__le16 sig_avg;
 	__le16 noise_diff;
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl3945_rx_frame_hdr {
 	__le16 channel;
@@ -1291,13 +1291,13 @@ struct iwl3945_rx_frame_hdr {
 	u8 rate;
 	__le16 len;
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl3945_rx_frame_end {
 	__le32 status;
 	__le64 timestamp;
 	__le32 beacon_timestamp;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_3945_RX = 0x1b (response only, not a command)
@@ -1311,7 +1311,7 @@ struct iwl3945_rx_frame {
 	struct iwl3945_rx_frame_stats stats;
 	struct iwl3945_rx_frame_hdr hdr;
 	struct iwl3945_rx_frame_end end;
-} __attribute__ ((packed));
+} __packed;
 
 #define IWL39_RX_FRAME_SIZE	(4 + sizeof(struct iwl3945_rx_frame))
 
@@ -1327,7 +1327,7 @@ struct iwl4965_rx_non_cfg_phy {
 	__le16 agc_info;	/* agc code 0:6, agc dB 7:13, reserved 14:15 */
 	u8 rssi_info[6];	/* we use even entries, 0/2/4 for A/B/C rssi */
 	u8 pad[0];
-} __attribute__ ((packed));
+} __packed;
 
 
 #define IWL50_RX_RES_PHY_CNT 8
@@ -1345,7 +1345,7 @@ struct iwl4965_rx_non_cfg_phy {
 
 struct iwl5000_non_cfg_phy {
 	__le32 non_cfg_phy[IWL50_RX_RES_PHY_CNT];  /* up to 8 phy entries */
-} __attribute__ ((packed));
+} __packed;
 
 
 /*
@@ -1365,12 +1365,12 @@ struct iwl_rx_phy_res {
 	__le32 rate_n_flags;	/* RATE_MCS_* */
 	__le16 byte_count;	/* frame's byte-count */
 	__le16 reserved3;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl4965_rx_mpdu_res_start {
 	__le16 byte_count;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 
 /******************************************************************************
@@ -1557,7 +1557,7 @@ struct iwl3945_tx_cmd {
 	 */
 	u8 payload[0];
 	struct ieee80211_hdr hdr[0];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_TX = 0x1c (response)
@@ -1569,7 +1569,7 @@ struct iwl3945_tx_resp {
 	u8 rate;
 	__le32 wireless_media_time;
 	__le32 status;		/* TX status */
-} __attribute__ ((packed));
+} __packed;
 
 
 /*
@@ -1581,7 +1581,7 @@ struct iwl_dram_scratch {
 	u8 try_cnt;		/* Tx attempts */
 	u8 bt_kill_cnt;		/* Tx attempts blocked by Bluetooth device */
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_tx_cmd {
 	/*
@@ -1660,7 +1660,7 @@ struct iwl_tx_cmd {
 	 */
 	u8 payload[0];
 	struct ieee80211_hdr hdr[0];
-} __attribute__ ((packed));
+} __packed;
 
 /* TX command response is sent after *3945* transmission attempts.
  *
@@ -1826,7 +1826,7 @@ enum {
 struct agg_tx_status {
 	__le16 status;
 	__le16 sequence;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl4965_tx_resp {
 	u8 frame_count;		/* 1 no aggregation, >1 aggregation */
@@ -1863,7 +1863,7 @@ struct iwl4965_tx_resp {
 		__le32 status;
 		struct agg_tx_status agg_status[0]; /* for each agg frame */
 	} u;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * definitions for initial rate index field
@@ -1927,7 +1927,7 @@ struct iwl5000_tx_resp {
 	 */
 	struct agg_tx_status status;	/* TX status (in aggregation -
 					 * status of 1st frame) */
-} __attribute__ ((packed));
+} __packed;
 /*
  * REPLY_COMPRESSED_BA = 0xc5 (response only, not a command)
  *
@@ -1945,7 +1945,7 @@ struct iwl_compressed_ba_resp {
 	__le64 bitmap;
 	__le16 scd_flow;
 	__le16 scd_ssn;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_TX_PWR_TABLE_CMD = 0x97 (command, has simple generic response)
@@ -1958,14 +1958,14 @@ struct iwl3945_txpowertable_cmd {
 	u8 reserved;
 	__le16 channel;
 	struct iwl3945_power_per_rate power[IWL_MAX_RATES];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl4965_txpowertable_cmd {
 	u8 band;		/* 0: 5 GHz, 1: 2.4 GHz */
 	u8 reserved;
 	__le16 channel;
 	struct iwl4965_tx_power_db tx_power;
-} __attribute__ ((packed));
+} __packed;
 
 
 /**
@@ -1987,13 +1987,13 @@ struct iwl3945_rate_scaling_info {
 	__le16 rate_n_flags;
 	u8 try_cnt;
 	u8 next_rate_index;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl3945_rate_scaling_cmd {
 	u8 table_id;
 	u8 reserved[3];
 	struct iwl3945_rate_scaling_info table[IWL_MAX_RATES];
-} __attribute__ ((packed));
+} __packed;
 
 
 /*RS_NEW_API: only TLC_RTS remains and moved to bit 0 */
@@ -2040,7 +2040,7 @@ struct iwl_link_qual_general_params {
 	 * TX FIFOs above 3 use same value (typically 0) as TX FIFO 3.
 	 */
 	u8 start_rate_index[LINK_QUAL_AC_NUM];
-} __attribute__ ((packed));
+} __packed;
 
 #define LINK_QUAL_AGG_TIME_LIMIT_DEF	(4000) /* 4 milliseconds */
 #define LINK_QUAL_AGG_TIME_LIMIT_MAX	(65535)
@@ -2081,7 +2081,7 @@ struct iwl_link_qual_agg_params {
 	u8 agg_frame_cnt_limit;
 
 	__le32 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_TX_LINK_QUALITY_CMD = 0x4e (command, has simple generic response)
@@ -2287,7 +2287,7 @@ struct iwl_link_quality_cmd {
 		__le32 rate_n_flags;	/* RATE_MCS_*, IWL_RATE_* */
 	} rs_table[LINK_QUAL_MAX_RETRY_NUM];
 	__le32 reserved2;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * BT configuration enable flags:
@@ -2328,7 +2328,7 @@ struct iwl_bt_cmd {
 	u8 reserved;
 	__le32 kill_ack_mask;
 	__le32 kill_cts_mask;
-} __attribute__ ((packed));
+} __packed;
 
 /******************************************************************************
  * (6)
@@ -2353,7 +2353,7 @@ struct iwl_measure_channel {
 	u8 channel;		/* channel to measure */
 	u8 type;		/* see enum iwl_measure_type */
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_SPECTRUM_MEASUREMENT_CMD = 0x74 (command)
@@ -2372,7 +2372,7 @@ struct iwl_spectrum_cmd {
 	__le16 channel_count;	/* minimum 1, maximum 10 */
 	__le16 reserved3;
 	struct iwl_measure_channel channels[10];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_SPECTRUM_MEASUREMENT_CMD = 0x74 (response)
@@ -2383,7 +2383,7 @@ struct iwl_spectrum_resp {
 	__le16 status;		/* 0 - command will be handled
 				 * 1 - cannot handle (conflicts with another
 				 *     measurement) */
-} __attribute__ ((packed));
+} __packed;
 
 enum iwl_measurement_state {
 	IWL_MEASUREMENT_START = 0,
@@ -2406,13 +2406,13 @@ enum iwl_measurement_status {
 struct iwl_measurement_histogram {
 	__le32 ofdm[NUM_ELEMENTS_IN_HISTOGRAM];	/* in 0.8usec counts */
 	__le32 cck[NUM_ELEMENTS_IN_HISTOGRAM];	/* in 1usec counts */
-} __attribute__ ((packed));
+} __packed;
 
 /* clear channel availability counters */
 struct iwl_measurement_cca_counters {
 	__le32 ofdm;
 	__le32 cck;
-} __attribute__ ((packed));
+} __packed;
 
 enum iwl_measure_type {
 	IWL_MEASURE_BASIC = (1 << 0),
@@ -2448,7 +2448,7 @@ struct iwl_spectrum_notification {
 	struct iwl_measurement_histogram histogram;
 	__le32 stop_time;	/* lower 32-bits of TSF */
 	__le32 status;		/* see iwl_measurement_status */
-} __attribute__ ((packed));
+} __packed;
 
 /******************************************************************************
  * (7)
@@ -2504,7 +2504,7 @@ struct iwl3945_powertable_cmd {
 	__le32 rx_data_timeout;
 	__le32 tx_data_timeout;
 	__le32 sleep_interval[IWL_POWER_VEC_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_powertable_cmd {
 	__le16 flags;
@@ -2514,7 +2514,7 @@ struct iwl_powertable_cmd {
 	__le32 tx_data_timeout;
 	__le32 sleep_interval[IWL_POWER_VEC_SIZE];
 	__le32 keep_alive_beacons;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * PM_SLEEP_NOTIFICATION = 0x7A (notification only, not a command)
@@ -2527,7 +2527,7 @@ struct iwl_sleep_notification {
 	__le32 sleep_time;
 	__le32 tsf_low;
 	__le32 bcon_timer;
-} __attribute__ ((packed));
+} __packed;
 
 /* Sleep states.  3945 and 4965 identical. */
 enum {
@@ -2552,14 +2552,14 @@ enum {
 #define CARD_STATE_CMD_HALT    0x02	/* Power down permanently */
 struct iwl_card_state_cmd {
 	__le32 status;		/* CARD_STATE_CMD_* request new power state */
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * CARD_STATE_NOTIFICATION = 0xa1 (notification only, not a command)
  */
 struct iwl_card_state_notif {
 	__le32 flags;
-} __attribute__ ((packed));
+} __packed;
 
 #define HW_CARD_DISABLED   0x01
 #define SW_CARD_DISABLED   0x02
@@ -2570,14 +2570,14 @@ struct iwl_ct_kill_config {
 	__le32   reserved;
 	__le32   critical_temperature_M;
 	__le32   critical_temperature_R;
-}  __attribute__ ((packed));
+}  __packed;
 
 /* 1000, and 6x00 */
 struct iwl_ct_kill_throttling_config {
 	__le32   critical_temperature_exit;
 	__le32   reserved;
 	__le32   critical_temperature_enter;
-}  __attribute__ ((packed));
+}  __packed;
 
 /******************************************************************************
  * (8)
@@ -2622,7 +2622,7 @@ struct iwl3945_scan_channel {
 	struct iwl3945_tx_power tpc;
 	__le16 active_dwell;	/* in 1024-uSec TU (time units), typ 5-50 */
 	__le16 passive_dwell;	/* in 1024-uSec TU (time units), typ 20-500 */
-} __attribute__ ((packed));
+} __packed;
 
 /* set number of direct probes u8 type */
 #define IWL39_SCAN_PROBE_MASK(n) ((BIT(n) | (BIT(n) - BIT(1))))
@@ -2641,7 +2641,7 @@ struct iwl_scan_channel {
 	u8 dsp_atten;		/* gain for DSP */
 	__le16 active_dwell;	/* in 1024-uSec TU (time units), typ 5-50 */
 	__le16 passive_dwell;	/* in 1024-uSec TU (time units), typ 20-500 */
-} __attribute__ ((packed));
+} __packed;
 
 /* set number of direct probes __le32 type */
 #define IWL_SCAN_PROBE_MASK(n) 	cpu_to_le32((BIT(n) | (BIT(n) - BIT(1))))
@@ -2658,7 +2658,7 @@ struct iwl_ssid_ie {
 	u8 id;
 	u8 len;
 	u8 ssid[32];
-} __attribute__ ((packed));
+} __packed;
 
 #define PROBE_OPTION_MAX_3945		4
 #define PROBE_OPTION_MAX		20
@@ -2764,7 +2764,7 @@ struct iwl3945_scan_cmd {
 	 * before requesting another scan.
 	 */
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_scan_cmd {
 	__le16 len;
@@ -2808,7 +2808,7 @@ struct iwl_scan_cmd {
 	 * before requesting another scan.
 	 */
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 /* Can abort will notify by complete notification with abort status. */
 #define CAN_ABORT_STATUS	cpu_to_le32(0x1)
@@ -2820,7 +2820,7 @@ struct iwl_scan_cmd {
  */
 struct iwl_scanreq_notification {
 	__le32 status;		/* 1: okay, 2: cannot fulfill request */
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * SCAN_START_NOTIFICATION = 0x82 (notification only, not a command)
@@ -2833,7 +2833,7 @@ struct iwl_scanstart_notification {
 	u8 band;
 	u8 reserved[2];
 	__le32 status;
-} __attribute__ ((packed));
+} __packed;
 
 #define  SCAN_OWNER_STATUS 0x1;
 #define  MEASURE_OWNER_STATUS 0x2;
@@ -2849,7 +2849,7 @@ struct iwl_scanresults_notification {
 	__le32 tsf_low;
 	__le32 tsf_high;
 	__le32 statistics[NUMBER_OF_STATISTICS];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * SCAN_COMPLETE_NOTIFICATION = 0x84 (notification only, not a command)
@@ -2861,7 +2861,7 @@ struct iwl_scancomplete_notification {
 	u8 last_channel;
 	__le32 tsf_low;
 	__le32 tsf_high;
-} __attribute__ ((packed));
+} __packed;
 
 
 /******************************************************************************
@@ -2879,14 +2879,14 @@ struct iwl3945_beacon_notif {
 	__le32 low_tsf;
 	__le32 high_tsf;
 	__le32 ibss_mgr_status;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl4965_beacon_notif {
 	struct iwl4965_tx_resp beacon_notify_hdr;
 	__le32 low_tsf;
 	__le32 high_tsf;
 	__le32 ibss_mgr_status;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * REPLY_TX_BEACON = 0x91 (command, has simple generic response)
@@ -2898,7 +2898,7 @@ struct iwl3945_tx_beacon_cmd {
 	u8 tim_size;
 	u8 reserved1;
 	struct ieee80211_hdr frame[0];	/* beacon frame */
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_tx_beacon_cmd {
 	struct iwl_tx_cmd tx;
@@ -2906,7 +2906,7 @@ struct iwl_tx_beacon_cmd {
 	u8 tim_size;
 	u8 reserved1;
 	struct ieee80211_hdr frame[0];	/* beacon frame */
-} __attribute__ ((packed));
+} __packed;
 
 /******************************************************************************
  * (10)
@@ -2932,7 +2932,7 @@ struct rate_histogram {
 		__le32 b[SUP_RATE_11B_MAX_NUM_CHANNELS];
 		__le32 g[SUP_RATE_11G_MAX_NUM_CHANNELS];
 	} failed;
-} __attribute__ ((packed));
+} __packed;
 
 /* statistics command response */
 
@@ -2952,7 +2952,7 @@ struct iwl39_statistics_rx_phy {
 	__le32 rxe_frame_limit_overrun;
 	__le32 sent_ack_cnt;
 	__le32 sent_cts_cnt;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl39_statistics_rx_non_phy {
 	__le32 bogus_cts;	/* CTS received when not expecting CTS */
@@ -2963,13 +2963,13 @@ struct iwl39_statistics_rx_non_phy {
 				 * filtering process */
 	__le32 non_channel_beacons;	/* beacons with our bss id but not on
 					 * our serving channel */
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl39_statistics_rx {
 	struct iwl39_statistics_rx_phy ofdm;
 	struct iwl39_statistics_rx_phy cck;
 	struct iwl39_statistics_rx_non_phy general;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl39_statistics_tx {
 	__le32 preamble_cnt;
@@ -2981,20 +2981,20 @@ struct iwl39_statistics_tx {
 	__le32 ack_timeout;
 	__le32 expected_ack_cnt;
 	__le32 actual_ack_cnt;
-} __attribute__ ((packed));
+} __packed;
 
 struct statistics_dbg {
 	__le32 burst_check;
 	__le32 burst_count;
 	__le32 reserved[4];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl39_statistics_div {
 	__le32 tx_on_a;
 	__le32 tx_on_b;
 	__le32 exec_time;
 	__le32 probe_time;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl39_statistics_general {
 	__le32 temperature;
@@ -3004,7 +3004,7 @@ struct iwl39_statistics_general {
 	__le32 slots_idle;
 	__le32 ttl_timestamp;
 	struct iwl39_statistics_div div;
-} __attribute__ ((packed));
+} __packed;
 
 struct statistics_rx_phy {
 	__le32 ina_cnt;
@@ -3027,7 +3027,7 @@ struct statistics_rx_phy {
 	__le32 mh_format_err;
 	__le32 re_acq_main_rssi_sum;
 	__le32 reserved3;
-} __attribute__ ((packed));
+} __packed;
 
 struct statistics_rx_ht_phy {
 	__le32 plcp_err;
@@ -3040,7 +3040,7 @@ struct statistics_rx_ht_phy {
 	__le32 agg_mpdu_cnt;
 	__le32 agg_cnt;
 	__le32 unsupport_mcs;
-} __attribute__ ((packed));
+} __packed;
 
 #define INTERFERENCE_DATA_AVAILABLE      cpu_to_le32(1)
 
@@ -3075,14 +3075,14 @@ struct statistics_rx_non_phy {
 	__le32 beacon_energy_a;
 	__le32 beacon_energy_b;
 	__le32 beacon_energy_c;
-} __attribute__ ((packed));
+} __packed;
 
 struct statistics_rx {
 	struct statistics_rx_phy ofdm;
 	struct statistics_rx_phy cck;
 	struct statistics_rx_non_phy general;
 	struct statistics_rx_ht_phy ofdm_ht;
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * struct statistics_tx_power - current tx power
@@ -3096,7 +3096,7 @@ struct statistics_tx_power {
 	u8 ant_b;
 	u8 ant_c;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct statistics_tx_non_phy_agg {
 	__le32 ba_timeout;
@@ -3109,7 +3109,7 @@ struct statistics_tx_non_phy_agg {
 	__le32 underrun;
 	__le32 bt_prio_kill;
 	__le32 rx_ba_rsp_cnt;
-} __attribute__ ((packed));
+} __packed;
 
 struct statistics_tx {
 	__le32 preamble_cnt;
@@ -3134,7 +3134,7 @@ struct statistics_tx {
 	 */
 	struct statistics_tx_power tx_power;
 	__le32 reserved1;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct statistics_div {
@@ -3144,7 +3144,7 @@ struct statistics_div {
 	__le32 probe_time;
 	__le32 reserved1;
 	__le32 reserved2;
-} __attribute__ ((packed));
+} __packed;
 
 struct statistics_general {
 	__le32 temperature;   /* radio temperature */
@@ -3164,7 +3164,7 @@ struct statistics_general {
 	__le32 num_of_sos_states;
 	__le32 reserved2;
 	__le32 reserved3;
-} __attribute__ ((packed));
+} __packed;
 
 #define UCODE_STATISTICS_CLEAR_MSK		(0x1 << 0)
 #define UCODE_STATISTICS_FREQUENCY_MSK		(0x1 << 1)
@@ -3189,7 +3189,7 @@ struct statistics_general {
 #define IWL_STATS_CONF_DISABLE_NOTIF cpu_to_le32(0x2)/* see above */
 struct iwl_statistics_cmd {
 	__le32 configuration_flags;	/* IWL_STATS_CONF_* */
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * STATISTICS_NOTIFICATION = 0x9d (notification only, not a command)
@@ -3214,14 +3214,14 @@ struct iwl3945_notif_statistics {
 	struct iwl39_statistics_rx rx;
 	struct iwl39_statistics_tx tx;
 	struct iwl39_statistics_general general;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_notif_statistics {
 	__le32 flag;
 	struct statistics_rx rx;
 	struct statistics_tx tx;
 	struct statistics_general general;
-} __attribute__ ((packed));
+} __packed;
 
 
 /*
@@ -3253,7 +3253,7 @@ struct iwl_missed_beacon_notif {
 	__le32 total_missed_becons;
 	__le32 num_expected_beacons;
 	__le32 num_recvd_beacons;
-} __attribute__ ((packed));
+} __packed;
 
 
 /******************************************************************************
@@ -3455,7 +3455,7 @@ struct iwl_missed_beacon_notif {
 struct iwl_sensitivity_cmd {
 	__le16 control;			/* always use "1" */
 	__le16 table[HD_TABLE_SIZE];	/* use HD_* as index */
-} __attribute__ ((packed));
+} __packed;
 
 
 /**
@@ -3536,31 +3536,31 @@ struct iwl_calib_cfg_elmnt_s {
 	__le32 send_res;
 	__le32 apply_res;
 	__le32 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_calib_cfg_status_s {
 	struct iwl_calib_cfg_elmnt_s once;
 	struct iwl_calib_cfg_elmnt_s perd;
 	__le32 flags;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_calib_cfg_cmd {
 	struct iwl_calib_cfg_status_s ucd_calib_cfg;
 	struct iwl_calib_cfg_status_s drv_calib_cfg;
 	__le32 reserved1;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_calib_hdr {
 	u8 op_code;
 	u8 first_group;
 	u8 groups_num;
 	u8 data_valid;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_calib_cmd {
 	struct iwl_calib_hdr hdr;
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 /* IWL_PHY_CALIBRATE_DIFF_GAIN_CMD (7) */
 struct iwl_calib_diff_gain_cmd {
@@ -3569,14 +3569,14 @@ struct iwl_calib_diff_gain_cmd {
 	s8 diff_gain_b;
 	s8 diff_gain_c;
 	u8 reserved1;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_calib_xtal_freq_cmd {
 	struct iwl_calib_hdr hdr;
 	u8 cap_pin1;
 	u8 cap_pin2;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 /* IWL_PHY_CALIBRATE_CHAIN_NOISE_RESET_CMD */
 struct iwl_calib_chain_noise_reset_cmd {
@@ -3590,7 +3590,7 @@ struct iwl_calib_chain_noise_gain_cmd {
 	u8 delta_gain_1;
 	u8 delta_gain_2;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 /******************************************************************************
  * (12)
@@ -3613,7 +3613,7 @@ struct iwl_led_cmd {
 	u8 on;			/* # intervals on while blinking;
 				 * "0", regardless of "off", turns LED off */
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * station priority table entries
@@ -3749,7 +3749,7 @@ struct iwl_wimax_coex_event_entry {
 	u8 win_medium_prio;
 	u8 reserved;
 	u8 flags;
-} __attribute__ ((packed));
+} __packed;
 
 /* COEX flag masks */
 
@@ -3766,7 +3766,7 @@ struct iwl_wimax_coex_cmd {
 	u8 flags;
 	u8 reserved[3];
 	struct iwl_wimax_coex_event_entry sta_prio[COEX_NUM_OF_EVENTS];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Coexistence MEDIUM NOTIFICATION
@@ -3795,7 +3795,7 @@ struct iwl_wimax_coex_cmd {
 struct iwl_coex_medium_notification {
 	__le32 status;
 	__le32 events;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Coexistence EVENT  Command
@@ -3810,11 +3810,11 @@ struct iwl_coex_event_cmd {
 	u8 flags;
 	u8 event;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwl_coex_event_resp {
 	__le32 status;
-} __attribute__ ((packed));
+} __packed;
 
 
 /******************************************************************************
@@ -3858,7 +3858,7 @@ struct iwl_rx_packet {
 		__le32 status;
 		u8 raw[0];
 	} u;
-} __attribute__ ((packed));
+} __packed;
 
 int iwl_agn_check_rxon_cmd(struct iwl_priv *priv);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index f3f3473..a36a6ef 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -157,7 +157,7 @@ struct iwl_queue {
 				* space more than this */
 	int high_mark;         /* high watermark, stop queue if free
 				* space less than this */
-} __attribute__ ((packed));
+} __packed;
 
 /* One for each TFD */
 struct iwl_tx_info {
@@ -343,8 +343,8 @@ struct iwl_device_cmd {
 		struct iwl_tx_cmd tx;
 		struct iwl6000_channel_switch_cmd chswitch;
 		u8 payload[DEF_CMD_PAYLOAD_SIZE];
-	} __attribute__ ((packed)) cmd;
-} __attribute__ ((packed));
+	} __packed cmd;
+} __packed;
 
 #define TFD_MAX_PAYLOAD_SIZE (sizeof(struct iwl_device_cmd))
 
@@ -590,7 +590,7 @@ struct iwl_ucode_tlv {
 	__le16 alternative;	/* see comment */
 	__le32 length;		/* not including type/length fields */
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 #define IWL_TLV_UCODE_MAGIC	0x0a4c5749
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.h b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
index 95aa202..5488006 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.h
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
@@ -118,7 +118,7 @@ enum {
 struct iwl_eeprom_channel {
 	u8 flags;		/* EEPROM_CHANNEL_* flags copied from EEPROM */
 	s8 max_power_avg;	/* max power (dBm) on this chnl, limit 31 */
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * iwl_eeprom_enhanced_txpwr structure
@@ -144,7 +144,7 @@ struct iwl_eeprom_enhanced_txpwr {
 	s8 reserved;
 	s8 mimo2_max;
 	s8 mimo3_max;
-} __attribute__ ((packed));
+} __packed;
 
 /* 3945 Specific */
 #define EEPROM_3945_EEPROM_VERSION	(0x2f)
@@ -312,7 +312,7 @@ struct iwl_eeprom_calib_measure {
 	u8 gain_idx;		/* Index into gain table */
 	u8 actual_pow;		/* Measured RF output power, half-dBm */
 	s8 pa_det;		/* Power amp detector level (not used) */
-} __attribute__ ((packed));
+} __packed;
 
 
 /*
@@ -328,7 +328,7 @@ struct iwl_eeprom_calib_ch_info {
 	struct iwl_eeprom_calib_measure
 		measurements[EEPROM_TX_POWER_TX_CHAINS]
 			[EEPROM_TX_POWER_MEASUREMENTS];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * txpower subband info.
@@ -345,7 +345,7 @@ struct iwl_eeprom_calib_subband_info {
 	u8 ch_to;	/* channel number of highest channel in subband */
 	struct iwl_eeprom_calib_ch_info ch1;
 	struct iwl_eeprom_calib_ch_info ch2;
-} __attribute__ ((packed));
+} __packed;
 
 
 /*
@@ -374,7 +374,7 @@ struct iwl_eeprom_calib_info {
 	__le16 voltage;		/* signed */
 	struct iwl_eeprom_calib_subband_info
 		band_info[EEPROM_TX_POWER_BANDS];
-} __attribute__ ((packed));
+} __packed;
 
 
 #define ADDRESS_MSK                 0x0000FFFF
diff --git a/drivers/net/wireless/iwlwifi/iwl-fh.h b/drivers/net/wireless/iwlwifi/iwl-fh.h
index 113c366..a3fcbb5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-fh.h
+++ b/drivers/net/wireless/iwlwifi/iwl-fh.h
@@ -449,7 +449,7 @@ struct iwl_rb_status {
 	__le16 finished_rb_num;
 	__le16 finished_fr_nam;
 	__le32 __unused; /* 3945 only */
-} __attribute__ ((packed));
+} __packed;
 
 
 #define TFD_QUEUE_SIZE_MAX      (256)
@@ -475,7 +475,7 @@ static inline u8 iwl_get_dma_hi_addr(dma_addr_t addr)
 struct iwl_tfd_tb {
 	__le32 lo;
 	__le16 hi_n_len;
-} __attribute__((packed));
+} __packed;
 
 /**
  * struct iwl_tfd
@@ -510,7 +510,7 @@ struct iwl_tfd {
 	u8 num_tbs;
 	struct iwl_tfd_tb tbs[IWL_NUM_OF_TBS];
 	__le32 __pad;
-} __attribute__ ((packed));
+} __packed;
 
 /* Keep Warm Size */
 #define IWL_KW_SIZE 0x1000	/* 4k */
diff --git a/drivers/net/wireless/iwlwifi/iwl-spectrum.h b/drivers/net/wireless/iwlwifi/iwl-spectrum.h
index af6babe..c4ca0b5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-spectrum.h
+++ b/drivers/net/wireless/iwlwifi/iwl-spectrum.h
@@ -42,7 +42,7 @@ struct ieee80211_basic_report {
 	__le64 start_time;
 	__le16 duration;
 	u8 map;
-} __attribute__ ((packed));
+} __packed;
 
 enum {				/* ieee80211_measurement_request.mode */
 	/* Bit 0 is reserved */
@@ -63,13 +63,13 @@ struct ieee80211_measurement_params {
 	u8 channel;
 	__le64 start_time;
 	__le16 duration;
-} __attribute__ ((packed));
+} __packed;
 
 struct ieee80211_info_element {
 	u8 id;
 	u8 len;
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct ieee80211_measurement_request {
 	struct ieee80211_info_element ie;
@@ -77,7 +77,7 @@ struct ieee80211_measurement_request {
 	u8 mode;
 	u8 type;
 	struct ieee80211_measurement_params params[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct ieee80211_measurement_report {
 	struct ieee80211_info_element ie;
@@ -87,6 +87,6 @@ struct ieee80211_measurement_report {
 	union {
 		struct ieee80211_basic_report basic[0];
 	} u;
-} __attribute__ ((packed));
+} __packed;
 
 #endif
diff --git a/drivers/net/wireless/iwmc3200wifi/commands.h b/drivers/net/wireless/iwmc3200wifi/commands.h
index 7e16bcf..6421689 100644
--- a/drivers/net/wireless/iwmc3200wifi/commands.h
+++ b/drivers/net/wireless/iwmc3200wifi/commands.h
@@ -56,7 +56,7 @@
 
 struct iwm_umac_cmd_reset {
 	__le32 flags;
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_PARAM_TBL_ORD_FIX    0x0
 #define UMAC_PARAM_TBL_ORD_VAR    0x1
@@ -220,37 +220,37 @@ struct iwm_umac_cmd_set_param_fix {
 	__le16 tbl;
 	__le16 key;
 	__le32 value;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_set_param_var {
 	__le16 tbl;
 	__le16 key;
 	__le16 len;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_get_param {
 	__le16 tbl;
 	__le16 key;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_get_param_resp {
 	__le16 tbl;
 	__le16 key;
 	__le16 len;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_eeprom_proxy_hdr {
 	__le32 type;
 	__le32 offset;
 	__le32 len;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_eeprom_proxy {
 	struct iwm_umac_cmd_eeprom_proxy_hdr hdr;
 	u8 buf[0];
-} __attribute__ ((packed));
+} __packed;
 
 #define IWM_UMAC_CMD_EEPROM_TYPE_READ       0x1
 #define IWM_UMAC_CMD_EEPROM_TYPE_WRITE      0x2
@@ -267,13 +267,13 @@ struct iwm_umac_channel_info {
 	u8 reserved;
 	u8 flags;
 	__le32 channels_mask;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_get_channel_list {
 	__le16 count;
 	__le16 reserved;
 	struct iwm_umac_channel_info ch[0];
-} __attribute__ ((packed));
+} __packed;
 
 
 /* UMAC WiFi interface commands */
@@ -304,7 +304,7 @@ struct iwm_umac_ssid {
 	u8 ssid_len;
 	u8 ssid[IEEE80211_MAX_SSID_LEN];
 	u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_scan_request {
 	struct iwm_umac_wifi_if hdr;
@@ -314,7 +314,7 @@ struct iwm_umac_cmd_scan_request {
 	u8 timeout; /* In seconds */
 	u8 reserved;
 	struct iwm_umac_ssid ssids[UMAC_WIFI_IF_PROBE_OPTION_MAX];
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_CIPHER_TYPE_NONE		0xFF
 #define UMAC_CIPHER_TYPE_USE_GROUPCAST	0x00
@@ -357,7 +357,7 @@ struct iwm_umac_security {
 	u8 ucast_cipher;
 	u8 mcast_cipher;
 	u8 flags;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_ibss {
 	u8 beacon_interval;	/* in millisecond */
@@ -366,7 +366,7 @@ struct iwm_umac_ibss {
 	u8 band;
 	u8 channel;
 	u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_MODE_BSS	0
 #define UMAC_MODE_IBSS	1
@@ -385,13 +385,13 @@ struct iwm_umac_profile {
 	__le16 flags;
 	u8 wireless_mode;
 	u8 bss_num;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_invalidate_profile {
 	struct iwm_umac_wifi_if hdr;
 	u8 reason;
 	u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 /* Encryption key commands */
 struct iwm_umac_key_wep40 {
@@ -400,7 +400,7 @@ struct iwm_umac_key_wep40 {
 	u8 key[WLAN_KEY_LEN_WEP40];
 	u8 static_key;
 	u8 reserved[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_key_wep104 {
 	struct iwm_umac_wifi_if hdr;
@@ -408,7 +408,7 @@ struct iwm_umac_key_wep104 {
 	u8 key[WLAN_KEY_LEN_WEP104];
 	u8 static_key;
 	u8 reserved[2];
-} __attribute__ ((packed));
+} __packed;
 
 #define IWM_TKIP_KEY_SIZE 16
 #define IWM_TKIP_MIC_SIZE 8
@@ -420,7 +420,7 @@ struct iwm_umac_key_tkip {
 	u8 tkip_key[IWM_TKIP_KEY_SIZE];
 	u8 mic_rx_key[IWM_TKIP_MIC_SIZE];
 	u8 mic_tx_key[IWM_TKIP_MIC_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_key_ccmp {
 	struct iwm_umac_wifi_if hdr;
@@ -428,27 +428,27 @@ struct iwm_umac_key_ccmp {
 	u8 iv_count[6];
 	u8 reserved[2];
 	u8 key[WLAN_KEY_LEN_CCMP];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_key_remove {
 	struct iwm_umac_wifi_if hdr;
 	struct iwm_umac_key_hdr key_hdr;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_tx_key_id {
 	struct iwm_umac_wifi_if hdr;
 	u8 key_idx;
 	u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_pwr_trigger {
 	struct iwm_umac_wifi_if hdr;
 	__le32 reseved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_stats_req {
 	__le32 flags;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_cmd_stop_resume_tx {
 	u8 flags;
@@ -456,7 +456,7 @@ struct iwm_umac_cmd_stop_resume_tx {
 	__le16 stop_resume_tid_msk;
 	__le16 last_seq_num[IWM_UMAC_TID_NR];
 	u16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 #define IWM_CMD_PMKID_ADD   1
 #define IWM_CMD_PMKID_DEL   2
@@ -468,7 +468,7 @@ struct iwm_umac_pmkid_update {
 	u8 bssid[ETH_ALEN];
 	__le16 reserved;
 	u8 pmkid[WLAN_PMKID_LEN];
-} __attribute__ ((packed));
+} __packed;
 
 /* LMAC commands */
 int iwm_read_mac(struct iwm_priv *iwm, u8 *mac);
diff --git a/drivers/net/wireless/iwmc3200wifi/iwm.h b/drivers/net/wireless/iwmc3200wifi/iwm.h
index 13266c3..51d7efa 100644
--- a/drivers/net/wireless/iwmc3200wifi/iwm.h
+++ b/drivers/net/wireless/iwmc3200wifi/iwm.h
@@ -162,7 +162,7 @@ struct iwm_umac_key_hdr {
 	u8 mac[ETH_ALEN];
 	u8 key_idx;
 	u8 multicast; /* BCast encrypt & BCast decrypt of frames FROM mac */
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_key {
 	struct iwm_umac_key_hdr hdr;
diff --git a/drivers/net/wireless/iwmc3200wifi/lmac.h b/drivers/net/wireless/iwmc3200wifi/lmac.h
index a855a99..5ddcdf8 100644
--- a/drivers/net/wireless/iwmc3200wifi/lmac.h
+++ b/drivers/net/wireless/iwmc3200wifi/lmac.h
@@ -43,7 +43,7 @@ struct iwm_lmac_hdr {
 	u8 id;
 	u8 flags;
 	__le16 seq_num;
-} __attribute__ ((packed));
+} __packed;
 
 /* LMAC commands */
 #define CALIB_CFG_FLAG_SEND_COMPLETE_NTFY_AFTER_MSK  0x1
@@ -54,23 +54,23 @@ struct iwm_lmac_cal_cfg_elt {
 	__le32 send_res; /* 1 for sending back results */
 	__le32 apply_res; /* 1 for applying calibration results to HW */
 	__le32 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_lmac_cal_cfg_status {
 	struct iwm_lmac_cal_cfg_elt init;
 	struct iwm_lmac_cal_cfg_elt periodic;
 	__le32 flags; /* CALIB_CFG_FLAG_SEND_COMPLETE_NTFY_AFTER_MSK */
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_lmac_cal_cfg_cmd {
 	struct iwm_lmac_cal_cfg_status ucode_cfg;
 	struct iwm_lmac_cal_cfg_status driver_cfg;
 	__le32 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_lmac_cal_cfg_resp {
 	__le32 status;
-} __attribute__ ((packed));
+} __packed;
 
 #define IWM_CARD_STATE_SW_HW_ENABLED	0x00
 #define IWM_CARD_STATE_HW_DISABLED	0x01
@@ -80,7 +80,7 @@ struct iwm_lmac_cal_cfg_resp {
 
 struct iwm_lmac_card_state {
 	__le32 flags;
-} __attribute__ ((packed));
+} __packed;
 
 /**
  * COEX_PRIORITY_TABLE_CMD
@@ -131,7 +131,7 @@ struct coex_event {
 	u8 win_med_prio;
 	u8 reserved;
 	u8 flags;
-} __attribute__ ((packed));
+} __packed;
 
 #define COEX_FLAGS_STA_TABLE_VALID_MSK		0x1
 #define COEX_FLAGS_UNASSOC_WAKEUP_UMASK_MSK	0x4
@@ -142,7 +142,7 @@ struct iwm_coex_prio_table_cmd {
 	u8 flags;
 	u8 reserved[3];
 	struct coex_event sta_prio[COEX_EVENTS_NUM];
-} __attribute__ ((packed));
+} __packed;
 
 /* Coexistence definitions
  *
@@ -192,7 +192,7 @@ struct iwm_ct_kill_cfg_cmd {
 	u32 exit_threshold;
 	u32 reserved;
 	u32 entry_threshold;
-} __attribute__ ((packed));
+} __packed;
 
 
 /* LMAC OP CODES */
@@ -428,7 +428,7 @@ struct iwm_lmac_calib_hdr {
 	u8 first_grp;
 	u8 grp_num;
 	u8 all_data_valid;
-} __attribute__ ((packed));
+} __packed;
 
 #define IWM_LMAC_CALIB_FREQ_GROUPS_NR	7
 #define IWM_CALIB_FREQ_GROUPS_NR	5
@@ -437,20 +437,20 @@ struct iwm_lmac_calib_hdr {
 struct iwm_calib_rxiq_entry {
 	u16 ptam_postdist_ars;
 	u16 ptam_postdist_arc;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_calib_rxiq_group {
 	struct iwm_calib_rxiq_entry mode[IWM_CALIB_DC_MODES_NR];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_lmac_calib_rxiq {
 	struct iwm_calib_rxiq_group group[IWM_LMAC_CALIB_FREQ_GROUPS_NR];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_calib_rxiq {
 	struct iwm_lmac_calib_hdr hdr;
 	struct iwm_calib_rxiq_group group[IWM_CALIB_FREQ_GROUPS_NR];
-} __attribute__ ((packed));
+} __packed;
 
 #define LMAC_STA_ID_SEED	0x0f
 #define LMAC_STA_ID_POS		0
@@ -463,7 +463,7 @@ struct iwm_lmac_power_report {
 	u8 pa_integ_res_A[3];
 	u8 pa_integ_res_B[3];
 	u8 pa_integ_res_C[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_lmac_tx_resp {
 	u8 frame_cnt; /* 1-no aggregation, greater then 1 - aggregation */
@@ -479,6 +479,6 @@ struct iwm_lmac_tx_resp {
 	u8 ra_tid;
 	__le16 frame_ctl;
 	__le32 status;
-} __attribute__ ((packed));
+} __packed;
 
 #endif
diff --git a/drivers/net/wireless/iwmc3200wifi/umac.h b/drivers/net/wireless/iwmc3200wifi/umac.h
index 0cbba3e..4a137d3 100644
--- a/drivers/net/wireless/iwmc3200wifi/umac.h
+++ b/drivers/net/wireless/iwmc3200wifi/umac.h
@@ -42,19 +42,19 @@
 struct iwm_udma_in_hdr {
 	__le32 cmd;
 	__le32 size;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_udma_out_nonwifi_hdr {
 	__le32 cmd;
 	__le32 addr;
 	__le32 op1_sz;
 	__le32 op2;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_udma_out_wifi_hdr {
 	__le32 cmd;
 	__le32 meta_data;
-} __attribute__ ((packed));
+} __packed;
 
 /* Sequence numbering */
 #define UMAC_WIFI_SEQ_NUM_BASE		1
@@ -408,12 +408,12 @@ struct iwm_rx_ticket {
 	__le16 flags;
 	u8 payload_offset; /* includes: MAC header, pad, IV */
 	u8 tail_len; /* includes: MIC, ICV, CRC (w/o STATUS) */
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_rx_mpdu_hdr {
 	__le16 len;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /* UMAC SW WIFI API */
 
@@ -421,31 +421,31 @@ struct iwm_dev_cmd_hdr {
 	u8 cmd;
 	u8 flags;
 	__le16 seq_num;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_fw_cmd_hdr {
 	__le32 meta_data;
 	struct iwm_dev_cmd_hdr cmd;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_wifi_out_hdr {
 	struct iwm_udma_out_wifi_hdr hw_hdr;
 	struct iwm_umac_fw_cmd_hdr sw_hdr;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_nonwifi_out_hdr {
 	struct iwm_udma_out_nonwifi_hdr hw_hdr;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_wifi_in_hdr {
 	struct iwm_udma_in_hdr hw_hdr;
 	struct iwm_umac_fw_cmd_hdr sw_hdr;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_nonwifi_in_hdr {
 	struct iwm_udma_in_hdr hw_hdr;
 	__le32 time_stamp;
-} __attribute__ ((packed));
+} __packed;
 
 #define IWM_UMAC_PAGE_SIZE	0x200
 
@@ -521,7 +521,7 @@ struct iwm_umac_notif_wifi_if {
 	u8 status;
 	u8 flags;
 	__le16 buf_size;
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_ROAM_REASON_FIRST_SELECTION	0x1
 #define UMAC_ROAM_REASON_AP_DEAUTH		0x2
@@ -535,7 +535,7 @@ struct iwm_umac_notif_assoc_start {
 	__le32 roam_reason;
 	u8 bssid[ETH_ALEN];
 	u8 reserved[2];
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_ASSOC_COMPLETE_SUCCESS		0x0
 #define UMAC_ASSOC_COMPLETE_FAILURE		0x1
@@ -546,7 +546,7 @@ struct iwm_umac_notif_assoc_complete {
 	u8 bssid[ETH_ALEN];
 	u8 band;
 	u8 channel;
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_PROFILE_INVALID_ASSOC_TIMEOUT	0x0
 #define UMAC_PROFILE_INVALID_ROAM_TIMEOUT	0x1
@@ -556,7 +556,7 @@ struct iwm_umac_notif_assoc_complete {
 struct iwm_umac_notif_profile_invalidate {
 	struct iwm_umac_notif_wifi_if mlme_hdr;
 	__le32 reason;
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_SCAN_RESULT_SUCCESS  0x0
 #define UMAC_SCAN_RESULT_ABORTED  0x1
@@ -568,7 +568,7 @@ struct iwm_umac_notif_scan_complete {
 	__le32 type;
 	__le32 result;
 	u8 seq_num;
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_OPCODE_ADD_MODIFY	0x0
 #define UMAC_OPCODE_REMOVE	0x1
@@ -582,7 +582,7 @@ struct iwm_umac_notif_sta_info {
 	u8 mac_addr[ETH_ALEN];
 	u8 sta_id; /* bits 0-3: station ID, bits 4-7: station color */
 	u8 flags;
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_BAND_2GHZ 0
 #define UMAC_BAND_5GHZ 1
@@ -601,7 +601,7 @@ struct iwm_umac_notif_bss_info {
 	s8 rssi;
 	u8 reserved;
 	u8 frame_buf[1];
-} __attribute__ ((packed));
+} __packed;
 
 #define IWM_BSS_REMOVE_INDEX_MSK           0x0fff
 #define IWM_BSS_REMOVE_FLAGS_MSK           0xfc00
@@ -614,13 +614,13 @@ struct iwm_umac_notif_bss_removed {
 	struct iwm_umac_notif_wifi_if mlme_hdr;
 	__le32 count;
 	__le16 entries[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_notif_mgt_frame {
 	struct iwm_umac_notif_wifi_if mlme_hdr;
 	__le16 len;
 	u8 frame[1];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_notif_alive {
 	struct iwm_umac_wifi_in_hdr hdr;
@@ -630,13 +630,13 @@ struct iwm_umac_notif_alive {
 	__le16 reserved2;
 	__le16 page_grp_count;
 	__le32 page_grp_state[IWM_MACS_OUT_GROUPS];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_notif_init_complete {
 	struct iwm_umac_wifi_in_hdr hdr;
 	__le16 status;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /* error categories */
 enum {
@@ -667,12 +667,12 @@ struct iwm_fw_error_hdr {
 	__le32 dbm_buf_end;
 	__le32 dbm_buf_write_ptr;
 	__le32 dbm_buf_cycle_cnt;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_notif_error {
 	struct iwm_umac_wifi_in_hdr hdr;
 	struct iwm_fw_error_hdr err;
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_DEALLOC_NTFY_CHANGES_CNT_POS	0
 #define UMAC_DEALLOC_NTFY_CHANGES_CNT_SEED	0xff
@@ -687,20 +687,20 @@ struct iwm_umac_notif_page_dealloc {
 	struct iwm_umac_wifi_in_hdr hdr;
 	__le32 changes;
 	__le32 grp_info[IWM_MACS_OUT_GROUPS];
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_notif_wifi_status {
 	struct iwm_umac_wifi_in_hdr hdr;
 	__le16 status;
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct iwm_umac_notif_rx_ticket {
 	struct iwm_umac_wifi_in_hdr hdr;
 	u8 num_tickets;
 	u8 reserved[3];
 	struct iwm_rx_ticket tickets[1];
-} __attribute__ ((packed));
+} __packed;
 
 /* Tx/Rx rates window (number of max of last update window per second) */
 #define UMAC_NTF_RATE_SAMPLE_NR	4
@@ -758,7 +758,7 @@ struct iwm_umac_notif_stats {
 	__le32 roam_unassoc;
 	__le32 roam_deauth;
 	__le32 roam_ap_loadblance;
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_STOP_TX_FLAG    0x1
 #define UMAC_RESUME_TX_FLAG  0x2
@@ -770,7 +770,7 @@ struct iwm_umac_notif_stop_resume_tx {
 	u8 flags; /* UMAC_*_TX_FLAG_* */
 	u8 sta_id;
 	__le16 stop_resume_tid_msk; /* tid bitmask */
-} __attribute__ ((packed));
+} __packed;
 
 #define UMAC_MAX_NUM_PMKIDS 4
 
@@ -779,7 +779,7 @@ struct iwm_umac_wifi_if {
 	u8 oid;
 	u8 flags;
 	__le16 buf_size;
-} __attribute__ ((packed));
+} __packed;
 
 #define IWM_SEQ_NUM_HOST_MSK	0x0000
 #define IWM_SEQ_NUM_UMAC_MSK	0x4000
diff --git a/drivers/net/wireless/libertas/host.h b/drivers/net/wireless/libertas/host.h
index 3809c0b..3bd5d3b 100644
--- a/drivers/net/wireless/libertas/host.h
+++ b/drivers/net/wireless/libertas/host.h
@@ -326,7 +326,7 @@ struct txpd {
 	u8 pktdelay_2ms;
 	/* reserved */
 	u8 reserved1;
-} __attribute__ ((packed));
+} __packed;
 
 /* RxPD Descriptor */
 struct rxpd {
@@ -339,8 +339,8 @@ struct rxpd {
 			u8 bss_type;
 			/* BSS number */
 			u8 bss_num;
-		} __attribute__ ((packed)) bss;
-	} __attribute__ ((packed)) u;
+		} __packed bss;
+	} __packed u;
 
 	/* SNR */
 	u8 snr;
@@ -366,14 +366,14 @@ struct rxpd {
 	/* Pkt Priority */
 	u8 priority;
 	u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_header {
 	__le16 command;
 	__le16 size;
 	__le16 seqnum;
 	__le16 result;
-} __attribute__ ((packed));
+} __packed;
 
 /* Generic structure to hold all key types. */
 struct enc_key {
@@ -387,7 +387,7 @@ struct enc_key {
 struct lbs_offset_value {
 	u32 offset;
 	u32 value;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Define data structure for CMD_GET_HW_SPEC
@@ -426,7 +426,7 @@ struct cmd_ds_get_hw_spec {
 
 	/*FW/HW capability */
 	__le32 fwcapinfo;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_subscribe_event {
 	struct cmd_header hdr;
@@ -440,7 +440,7 @@ struct cmd_ds_802_11_subscribe_event {
 	 * bump this up a bit.
 	 */
 	uint8_t tlv[128];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * This scan handle Country Information IE(802.11d compliant)
@@ -452,7 +452,7 @@ struct cmd_ds_802_11_scan {
 	uint8_t bsstype;
 	uint8_t bssid[ETH_ALEN];
 	uint8_t tlvbuffer[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_scan_rsp {
 	struct cmd_header hdr;
@@ -460,7 +460,7 @@ struct cmd_ds_802_11_scan_rsp {
 	__le16 bssdescriptsize;
 	uint8_t nr_sets;
 	uint8_t bssdesc_and_tlvbuffer[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_get_log {
 	struct cmd_header hdr;
@@ -478,20 +478,20 @@ struct cmd_ds_802_11_get_log {
 	__le32 fcserror;
 	__le32 txframe;
 	__le32 wepundecryptable;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_mac_control {
 	struct cmd_header hdr;
 	__le16 action;
 	u16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_mac_multicast_adr {
 	struct cmd_header hdr;
 	__le16 action;
 	__le16 nr_of_adrs;
 	u8 maclist[ETH_ALEN * MRVDRV_MAX_MULTICAST_LIST_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_authenticate {
 	struct cmd_header hdr;
@@ -499,14 +499,14 @@ struct cmd_ds_802_11_authenticate {
 	u8 bssid[ETH_ALEN];
 	u8 authtype;
 	u8 reserved[10];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_deauthenticate {
 	struct cmd_header hdr;
 
 	u8 macaddr[ETH_ALEN];
 	__le16 reasoncode;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_associate {
 	struct cmd_header hdr;
@@ -517,7 +517,7 @@ struct cmd_ds_802_11_associate {
 	__le16 bcnperiod;
 	u8 dtimperiod;
 	u8 iebuf[512];    /* Enough for required and most optional IEs */
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_associate_response {
 	struct cmd_header hdr;
@@ -526,7 +526,7 @@ struct cmd_ds_802_11_associate_response {
 	__le16 statuscode;
 	__le16 aid;
 	u8 iebuf[512];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_set_wep {
 	struct cmd_header hdr;
@@ -540,7 +540,7 @@ struct cmd_ds_802_11_set_wep {
 	/* 40, 128bit or TXWEP */
 	uint8_t keytype[4];
 	uint8_t keymaterial[4][16];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_snmp_mib {
 	struct cmd_header hdr;
@@ -549,40 +549,40 @@ struct cmd_ds_802_11_snmp_mib {
 	__le16 oid;
 	__le16 bufsize;
 	u8 value[128];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_mac_reg_access {
 	__le16 action;
 	__le16 offset;
 	__le32 value;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_bbp_reg_access {
 	__le16 action;
 	__le16 offset;
 	u8 value;
 	u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_rf_reg_access {
 	__le16 action;
 	__le16 offset;
 	u8 value;
 	u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_radio_control {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le16 control;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_beacon_control {
 	__le16 action;
 	__le16 beacon_enable;
 	__le16 beacon_period;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_sleep_params {
 	struct cmd_header hdr;
@@ -607,7 +607,7 @@ struct cmd_ds_802_11_sleep_params {
 
 	/* reserved field, should be set to zero */
 	__le16 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_rf_channel {
 	struct cmd_header hdr;
@@ -617,7 +617,7 @@ struct cmd_ds_802_11_rf_channel {
 	__le16 rftype;      /* unused */
 	__le16 reserved;    /* unused */
 	u8 channellist[32]; /* unused */
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_rssi {
 	/* weighting factor */
@@ -626,21 +626,21 @@ struct cmd_ds_802_11_rssi {
 	__le16 reserved_0;
 	__le16 reserved_1;
 	__le16 reserved_2;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_rssi_rsp {
 	__le16 SNR;
 	__le16 noisefloor;
 	__le16 avgSNR;
 	__le16 avgnoisefloor;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_mac_address {
 	struct cmd_header hdr;
 
 	__le16 action;
 	u8 macadd[ETH_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_rf_tx_power {
 	struct cmd_header hdr;
@@ -649,26 +649,26 @@ struct cmd_ds_802_11_rf_tx_power {
 	__le16 curlevel;
 	s8 maxlevel;
 	s8 minlevel;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_monitor_mode {
 	__le16 action;
 	__le16 mode;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_set_boot2_ver {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le16 version;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_fw_wake_method {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le16 method;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_ps_mode {
 	__le16 action;
@@ -676,7 +676,7 @@ struct cmd_ds_802_11_ps_mode {
 	__le16 multipledtim;
 	__le16 reserved;
 	__le16 locallisteninterval;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_confirm_sleep {
 	struct cmd_header hdr;
@@ -686,7 +686,7 @@ struct cmd_confirm_sleep {
 	__le16 multipledtim;
 	__le16 reserved;
 	__le16 locallisteninterval;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_data_rate {
 	struct cmd_header hdr;
@@ -694,14 +694,14 @@ struct cmd_ds_802_11_data_rate {
 	__le16 action;
 	__le16 reserved;
 	u8 rates[MAX_RATES];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_rate_adapt_rateset {
 	struct cmd_header hdr;
 	__le16 action;
 	__le16 enablehwauto;
 	__le16 bitmap;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_ad_hoc_start {
 	struct cmd_header hdr;
@@ -718,14 +718,14 @@ struct cmd_ds_802_11_ad_hoc_start {
 	__le16 capability;
 	u8 rates[MAX_RATES];
 	u8 tlv_memory_size_pad[100];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_ad_hoc_result {
 	struct cmd_header hdr;
 
 	u8 pad[3];
 	u8 bssid[ETH_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct adhoc_bssdesc {
 	u8 bssid[ETH_ALEN];
@@ -746,7 +746,7 @@ struct adhoc_bssdesc {
 	 * Adhoc join command and will cause a binary layout mismatch with
 	 * the firmware
 	 */
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_ad_hoc_join {
 	struct cmd_header hdr;
@@ -754,18 +754,18 @@ struct cmd_ds_802_11_ad_hoc_join {
 	struct adhoc_bssdesc bss;
 	__le16 failtimeout;   /* Reserved on v9 and later */
 	__le16 probedelay;    /* Reserved on v9 and later */
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_ad_hoc_stop {
 	struct cmd_header hdr;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_enable_rsn {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le16 enable;
-} __attribute__ ((packed));
+} __packed;
 
 struct MrvlIEtype_keyParamSet {
 	/* type ID */
@@ -785,7 +785,7 @@ struct MrvlIEtype_keyParamSet {
 
 	/* key material of size keylen */
 	u8 key[32];
-} __attribute__ ((packed));
+} __packed;
 
 #define MAX_WOL_RULES 		16
 
@@ -797,7 +797,7 @@ struct host_wol_rule {
 	__le16 reserve;
 	__be32 sig_mask;
 	__be32 signature;
-} __attribute__ ((packed));
+} __packed;
 
 struct wol_config {
 	uint8_t action;
@@ -805,7 +805,7 @@ struct wol_config {
 	uint8_t no_rules_in_cmd;
 	uint8_t result;
 	struct host_wol_rule rule[MAX_WOL_RULES];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_host_sleep {
 	struct cmd_header hdr;
@@ -813,7 +813,7 @@ struct cmd_ds_host_sleep {
 	uint8_t gpio;
 	uint16_t gap;
 	struct wol_config wol_conf;
-} __attribute__ ((packed));
+} __packed;
 
 
 
@@ -822,7 +822,7 @@ struct cmd_ds_802_11_key_material {
 
 	__le16 action;
 	struct MrvlIEtype_keyParamSet keyParamSet[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_eeprom_access {
 	struct cmd_header hdr;
@@ -832,7 +832,7 @@ struct cmd_ds_802_11_eeprom_access {
 	/* firmware says it returns a maximum of 20 bytes */
 #define LBS_EEPROM_READ_LEN 20
 	u8 value[LBS_EEPROM_READ_LEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_tpc_cfg {
 	struct cmd_header hdr;
@@ -843,7 +843,7 @@ struct cmd_ds_802_11_tpc_cfg {
 	int8_t P1;
 	int8_t P2;
 	uint8_t usesnr;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct cmd_ds_802_11_pa_cfg {
@@ -854,14 +854,14 @@ struct cmd_ds_802_11_pa_cfg {
 	int8_t P0;
 	int8_t P1;
 	int8_t P2;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct cmd_ds_802_11_led_ctrl {
 	__le16 action;
 	__le16 numled;
 	u8 data[256];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_802_11_afc {
 	__le16 afc_auto;
@@ -875,22 +875,22 @@ struct cmd_ds_802_11_afc {
 			__le16 carrier_offset; /* signed */
 		};
 	};
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_tx_rate_query {
 	__le16 txrate;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_get_tsf {
 	__le64 tsfvalue;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_bt_access {
 	__le16 action;
 	__le32 id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_fwt_access {
 	__le16 action;
@@ -910,7 +910,7 @@ struct cmd_ds_fwt_access {
 	__le32 snr;
 	__le32 references;
 	u8 prec[ETH_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_mesh_config {
 	struct cmd_header hdr;
@@ -920,14 +920,14 @@ struct cmd_ds_mesh_config {
 	__le16 type;
 	__le16 length;
 	u8 data[128];	/* last position reserved */
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_mesh_access {
 	struct cmd_header hdr;
 
 	__le16 action;
 	__le32 data[32];	/* last position reserved */
-} __attribute__ ((packed));
+} __packed;
 
 /* Number of stats counters returned by the firmware */
 #define MESH_STATS_NUM 8
@@ -957,6 +957,6 @@ struct cmd_ds_command {
 		struct cmd_ds_fwt_access fwt;
 		struct cmd_ds_802_11_beacon_control bcn_ctrl;
 	} params;
-} __attribute__ ((packed));
+} __packed;
 
 #endif
diff --git a/drivers/net/wireless/libertas/radiotap.h b/drivers/net/wireless/libertas/radiotap.h
index d16b264..b3c8ea6 100644
--- a/drivers/net/wireless/libertas/radiotap.h
+++ b/drivers/net/wireless/libertas/radiotap.h
@@ -6,7 +6,7 @@ struct tx_radiotap_hdr {
 	u8 txpower;
 	u8 rts_retries;
 	u8 data_retries;
-} __attribute__ ((packed));
+} __packed;
 
 #define TX_RADIOTAP_PRESENT (				\
 	(1 << IEEE80211_RADIOTAP_RATE) |		\
@@ -34,7 +34,7 @@ struct rx_radiotap_hdr {
 	u8 flags;
 	u8 rate;
 	u8 antsignal;
-} __attribute__ ((packed));
+} __packed;
 
 #define RX_RADIOTAP_PRESENT (			\
 	(1 << IEEE80211_RADIOTAP_FLAGS) |	\
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index 7a377f5..1c63f8c 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -15,7 +15,7 @@ struct eth803hdr {
 	u8 dest_addr[6];
 	u8 src_addr[6];
 	u16 h803_len;
-} __attribute__ ((packed));
+} __packed;
 
 struct rfc1042hdr {
 	u8 llc_dsap;
@@ -23,17 +23,17 @@ struct rfc1042hdr {
 	u8 llc_ctrl;
 	u8 snap_oui[3];
 	u16 snap_type;
-} __attribute__ ((packed));
+} __packed;
 
 struct rxpackethdr {
 	struct eth803hdr eth803_hdr;
 	struct rfc1042hdr rfc1042_hdr;
-} __attribute__ ((packed));
+} __packed;
 
 struct rx80211packethdr {
 	struct rxpd rx_pd;
 	void *eth80211_hdr;
-} __attribute__ ((packed));
+} __packed;
 
 static int process_rxed_802_11_packet(struct lbs_private *priv,
 	struct sk_buff *skb);
diff --git a/drivers/net/wireless/libertas/types.h b/drivers/net/wireless/libertas/types.h
index 3e72c86..462fbb4 100644
--- a/drivers/net/wireless/libertas/types.h
+++ b/drivers/net/wireless/libertas/types.h
@@ -11,7 +11,7 @@
 struct ieee_ie_header {
 	u8 id;
 	u8 len;
-} __attribute__ ((packed));
+} __packed;
 
 struct ieee_ie_cf_param_set {
 	struct ieee_ie_header header;
@@ -20,19 +20,19 @@ struct ieee_ie_cf_param_set {
 	u8 cfpperiod;
 	__le16 cfpmaxduration;
 	__le16 cfpdurationremaining;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct ieee_ie_ibss_param_set {
 	struct ieee_ie_header header;
 
 	__le16 atimwindow;
-} __attribute__ ((packed));
+} __packed;
 
 union ieee_ss_param_set {
 	struct ieee_ie_cf_param_set cf;
 	struct ieee_ie_ibss_param_set ibss;
-} __attribute__ ((packed));
+} __packed;
 
 struct ieee_ie_fh_param_set {
 	struct ieee_ie_header header;
@@ -41,18 +41,18 @@ struct ieee_ie_fh_param_set {
 	u8 hopset;
 	u8 hoppattern;
 	u8 hopindex;
-} __attribute__ ((packed));
+} __packed;
 
 struct ieee_ie_ds_param_set {
 	struct ieee_ie_header header;
 
 	u8 channel;
-} __attribute__ ((packed));
+} __packed;
 
 union ieee_phy_param_set {
 	struct ieee_ie_fh_param_set fh;
 	struct ieee_ie_ds_param_set ds;
-} __attribute__ ((packed));
+} __packed;
 
 /** TLV  type ID definition */
 #define PROPRIETARY_TLV_BASE_ID		0x0100
@@ -100,28 +100,28 @@ union ieee_phy_param_set {
 struct mrvl_ie_header {
 	__le16 type;
 	__le16 len;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_data {
 	struct mrvl_ie_header header;
 	u8 Data[1];
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_rates_param_set {
 	struct mrvl_ie_header header;
 	u8 rates[1];
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_ssid_param_set {
 	struct mrvl_ie_header header;
 	u8 ssid[1];
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_wildcard_ssid_param_set {
 	struct mrvl_ie_header header;
 	u8 MaxSsidlength;
 	u8 ssid[1];
-} __attribute__ ((packed));
+} __packed;
 
 struct chanscanmode {
 #ifdef __BIG_ENDIAN_BITFIELD
@@ -133,7 +133,7 @@ struct chanscanmode {
 	u8 disablechanfilt:1;
 	u8 reserved_2_7:6;
 #endif
-} __attribute__ ((packed));
+} __packed;
 
 struct chanscanparamset {
 	u8 radiotype;
@@ -141,12 +141,12 @@ struct chanscanparamset {
 	struct chanscanmode chanscanmode;
 	__le16 minscantime;
 	__le16 maxscantime;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_chanlist_param_set {
 	struct mrvl_ie_header header;
 	struct chanscanparamset chanscanparam[1];
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_cf_param_set {
 	struct mrvl_ie_header header;
@@ -154,86 +154,86 @@ struct mrvl_ie_cf_param_set {
 	u8 cfpperiod;
 	__le16 cfpmaxduration;
 	__le16 cfpdurationremaining;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_ds_param_set {
 	struct mrvl_ie_header header;
 	u8 channel;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_rsn_param_set {
 	struct mrvl_ie_header header;
 	u8 rsnie[1];
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_tsf_timestamp {
 	struct mrvl_ie_header header;
 	__le64 tsftable[1];
-} __attribute__ ((packed));
+} __packed;
 
 /* v9 and later firmware only */
 struct mrvl_ie_auth_type {
 	struct mrvl_ie_header header;
 	__le16 auth;
-} __attribute__ ((packed));
+} __packed;
 
 /**  Local Power capability */
 struct mrvl_ie_power_capability {
 	struct mrvl_ie_header header;
 	s8 minpower;
 	s8 maxpower;
-} __attribute__ ((packed));
+} __packed;
 
 /* used in CMD_802_11_SUBSCRIBE_EVENT for SNR, RSSI and Failure */
 struct mrvl_ie_thresholds {
 	struct mrvl_ie_header header;
 	u8 value;
 	u8 freq;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_beacons_missed {
 	struct mrvl_ie_header header;
 	u8 beaconmissed;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_num_probes {
 	struct mrvl_ie_header header;
 	__le16 numprobes;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_bcast_probe {
 	struct mrvl_ie_header header;
 	__le16 bcastprobe;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_num_ssid_probe {
 	struct mrvl_ie_header header;
 	__le16 numssidprobe;
-} __attribute__ ((packed));
+} __packed;
 
 struct led_pin {
 	u8 led;
 	u8 pin;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_ie_ledgpio {
 	struct mrvl_ie_header header;
 	struct led_pin ledpin[1];
-} __attribute__ ((packed));
+} __packed;
 
 struct led_bhv {
 	uint8_t	firmwarestate;
 	uint8_t	led;
 	uint8_t	ledstate;
 	uint8_t	ledarg;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct mrvl_ie_ledbhv {
 	struct mrvl_ie_header header;
 	struct led_bhv ledbhv[1];
-} __attribute__ ((packed));
+} __packed;
 
 /* Meant to be packed as the value member of a struct ieee80211_info_element.
  * Note that the len member of the ieee80211_info_element varies depending on
@@ -248,12 +248,12 @@ struct mrvl_meshie_val {
 	uint8_t mesh_capability;
 	uint8_t mesh_id_len;
 	uint8_t mesh_id[IEEE80211_MAX_SSID_LEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_meshie {
 	u8 id, len;
 	struct mrvl_meshie_val val;
-} __attribute__ ((packed));
+} __packed;
 
 struct mrvl_mesh_defaults {
 	__le32 bootflag;
@@ -261,6 +261,6 @@ struct mrvl_mesh_defaults {
 	uint8_t reserved;
 	__le16 channel;
 	struct mrvl_meshie meshie;
-} __attribute__ ((packed));
+} __packed;
 
 #endif
diff --git a/drivers/net/wireless/libertas_tf/libertas_tf.h b/drivers/net/wireless/libertas_tf/libertas_tf.h
index fbbaaae..737eac9 100644
--- a/drivers/net/wireless/libertas_tf/libertas_tf.h
+++ b/drivers/net/wireless/libertas_tf/libertas_tf.h
@@ -316,7 +316,7 @@ struct cmd_header {
 	__le16 size;
 	__le16 seqnum;
 	__le16 result;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ctrl_node {
 	struct list_head list;
@@ -369,7 +369,7 @@ struct cmd_ds_get_hw_spec {
 
 	/*FW/HW capability */
 	__le32 fwcapinfo;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_ds_mac_control {
 	struct cmd_header hdr;
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 6f8cb3e..49a7dfb 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -317,7 +317,7 @@ struct hwsim_radiotap_hdr {
 	u8 rt_rate;
 	__le16 rt_channel;
 	__le16 rt_chbitmask;
-} __attribute__ ((packed));
+} __packed;
 
 
 static netdev_tx_t hwsim_mon_xmit(struct sk_buff *skb,
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 808adb9..60a8191 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -426,7 +426,7 @@ struct mwl8k_cmd_pkt {
 	__u8	macid;
 	__le16	result;
 	char	payload[0];
-} __attribute__((packed));
+} __packed;
 
 /*
  * Firmware loading.
@@ -632,7 +632,7 @@ struct mwl8k_dma_data {
 	__le16 fwlen;
 	struct ieee80211_hdr wh;
 	char data[0];
-} __attribute__((packed));
+} __packed;
 
 /* Routines to add/remove DMA header from skb.  */
 static inline void mwl8k_remove_dma_header(struct sk_buff *skb, __le16 qos)
@@ -711,7 +711,7 @@ struct mwl8k_rxd_8366_ap {
 	__u8 rx_status;
 	__u8 channel;
 	__u8 rx_ctrl;
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_8366_AP_RATE_INFO_MCS_FORMAT	0x80
 #define MWL8K_8366_AP_RATE_INFO_40MHZ		0x40
@@ -806,7 +806,7 @@ struct mwl8k_rxd_sta {
 	__u8 rx_ctrl;
 	__u8 rx_status;
 	__u8 pad2[2];
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_STA_RATE_INFO_SHORTPRE		0x8000
 #define MWL8K_STA_RATE_INFO_ANTSELECT(x)	(((x) >> 11) & 0x3)
@@ -1120,7 +1120,7 @@ struct mwl8k_tx_desc {
 	__le16 rate_info;
 	__u8 peer_id;
 	__u8 tx_frag_cnt;
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_TX_DESCS		128
 
@@ -1666,7 +1666,7 @@ struct mwl8k_cmd_get_hw_spec_sta {
 	__le32 caps2;
 	__le32 num_tx_desc_per_queue;
 	__le32 total_rxd;
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_CAP_MAX_AMSDU		0x20000000
 #define MWL8K_CAP_GREENFIELD		0x08000000
@@ -1810,7 +1810,7 @@ struct mwl8k_cmd_get_hw_spec_ap {
 	__le32 wcbbase1;
 	__le32 wcbbase2;
 	__le32 wcbbase3;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_get_hw_spec_ap(struct ieee80211_hw *hw)
 {
@@ -1883,7 +1883,7 @@ struct mwl8k_cmd_set_hw_spec {
 	__le32 flags;
 	__le32 num_tx_desc_per_queue;
 	__le32 total_rxd;
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_SET_HW_SPEC_FLAG_HOST_DECR_MGMT		0x00000080
 #define MWL8K_SET_HW_SPEC_FLAG_HOSTFORM_PROBERESP	0x00000020
@@ -1985,7 +1985,7 @@ __mwl8k_cmd_mac_multicast_adr(struct ieee80211_hw *hw, int allmulti,
 struct mwl8k_cmd_get_stat {
 	struct mwl8k_cmd_pkt header;
 	__le32 stats[64];
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_STAT_ACK_FAILURE	9
 #define MWL8K_STAT_RTS_FAILURE	12
@@ -2029,7 +2029,7 @@ struct mwl8k_cmd_radio_control {
 	__le16 action;
 	__le16 control;
 	__le16 radio_on;
-} __attribute__((packed));
+} __packed;
 
 static int
 mwl8k_cmd_radio_control(struct ieee80211_hw *hw, bool enable, bool force)
@@ -2092,7 +2092,7 @@ struct mwl8k_cmd_rf_tx_power {
 	__le16 current_level;
 	__le16 reserved;
 	__le16 power_level_list[MWL8K_TX_POWER_LEVEL_TOTAL];
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_rf_tx_power(struct ieee80211_hw *hw, int dBm)
 {
@@ -2121,7 +2121,7 @@ struct mwl8k_cmd_rf_antenna {
 	struct mwl8k_cmd_pkt header;
 	__le16 antenna;
 	__le16 mode;
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_RF_ANTENNA_RX		1
 #define MWL8K_RF_ANTENNA_TX		2
@@ -2182,7 +2182,7 @@ static int mwl8k_cmd_set_beacon(struct ieee80211_hw *hw,
  */
 struct mwl8k_cmd_set_pre_scan {
 	struct mwl8k_cmd_pkt header;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_set_pre_scan(struct ieee80211_hw *hw)
 {
@@ -2209,7 +2209,7 @@ struct mwl8k_cmd_set_post_scan {
 	struct mwl8k_cmd_pkt header;
 	__le32 isibss;
 	__u8 bssid[ETH_ALEN];
-} __attribute__((packed));
+} __packed;
 
 static int
 mwl8k_cmd_set_post_scan(struct ieee80211_hw *hw, const __u8 *mac)
@@ -2240,7 +2240,7 @@ struct mwl8k_cmd_set_rf_channel {
 	__le16 action;
 	__u8 current_channel;
 	__le32 channel_flags;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_set_rf_channel(struct ieee80211_hw *hw,
 				    struct ieee80211_conf *conf)
@@ -2293,7 +2293,7 @@ struct mwl8k_cmd_update_set_aid {
 	__u8	bssid[ETH_ALEN];
 	__le16	protection_mode;
 	__u8	supp_rates[14];
-} __attribute__((packed));
+} __packed;
 
 static void legacy_rate_mask_to_array(u8 *rates, u32 mask)
 {
@@ -2364,7 +2364,7 @@ struct mwl8k_cmd_set_rate {
 	/* Bitmap for supported MCS codes.  */
 	__u8	mcs_set[16];
 	__u8	reserved[16];
-} __attribute__((packed));
+} __packed;
 
 static int
 mwl8k_cmd_set_rate(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
@@ -2397,7 +2397,7 @@ struct mwl8k_cmd_finalize_join {
 	struct mwl8k_cmd_pkt header;
 	__le32 sleep_interval;	/* Number of beacon periods to sleep */
 	__u8 beacon_data[MWL8K_FJ_BEACON_MAXLEN];
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_finalize_join(struct ieee80211_hw *hw, void *frame,
 				   int framelen, int dtim)
@@ -2436,7 +2436,7 @@ struct mwl8k_cmd_set_rts_threshold {
 	struct mwl8k_cmd_pkt header;
 	__le16 action;
 	__le16 threshold;
-} __attribute__((packed));
+} __packed;
 
 static int
 mwl8k_cmd_set_rts_threshold(struct ieee80211_hw *hw, int rts_thresh)
@@ -2466,7 +2466,7 @@ struct mwl8k_cmd_set_slot {
 	struct mwl8k_cmd_pkt header;
 	__le16 action;
 	__u8 short_slot;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_set_slot(struct ieee80211_hw *hw, bool short_slot_time)
 {
@@ -2528,7 +2528,7 @@ struct mwl8k_cmd_set_edca_params {
 			__u8 txq;
 		} sta;
 	};
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_SET_EDCA_CW	0x01
 #define MWL8K_SET_EDCA_TXOP	0x02
@@ -2579,7 +2579,7 @@ mwl8k_cmd_set_edca_params(struct ieee80211_hw *hw, __u8 qnum,
 struct mwl8k_cmd_set_wmm_mode {
 	struct mwl8k_cmd_pkt header;
 	__le16 action;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_set_wmm_mode(struct ieee80211_hw *hw, bool enable)
 {
@@ -2612,7 +2612,7 @@ struct mwl8k_cmd_mimo_config {
 	__le32 action;
 	__u8 rx_antenna_map;
 	__u8 tx_antenna_map;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_mimo_config(struct ieee80211_hw *hw, __u8 rx, __u8 tx)
 {
@@ -2652,7 +2652,7 @@ struct mwl8k_cmd_use_fixed_rate_sta {
 	__le32 rate_type;
 	__le32 reserved1;
 	__le32 reserved2;
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_USE_AUTO_RATE	0x0002
 #define MWL8K_UCAST_RATE	0
@@ -2694,7 +2694,7 @@ struct mwl8k_cmd_use_fixed_rate_ap {
 	u8 multicast_rate;
 	u8 multicast_rate_type;
 	u8 management_rate;
-} __attribute__((packed));
+} __packed;
 
 static int
 mwl8k_cmd_use_fixed_rate_ap(struct ieee80211_hw *hw, int mcast, int mgmt)
@@ -2724,7 +2724,7 @@ mwl8k_cmd_use_fixed_rate_ap(struct ieee80211_hw *hw, int mcast, int mgmt)
 struct mwl8k_cmd_enable_sniffer {
 	struct mwl8k_cmd_pkt header;
 	__le32 action;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_enable_sniffer(struct ieee80211_hw *hw, bool enable)
 {
@@ -2757,7 +2757,7 @@ struct mwl8k_cmd_set_mac_addr {
 		} mbss;
 		__u8 mac_addr[ETH_ALEN];
 	};
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_MAC_TYPE_PRIMARY_CLIENT		0
 #define MWL8K_MAC_TYPE_SECONDARY_CLIENT		1
@@ -2812,7 +2812,7 @@ struct mwl8k_cmd_set_rate_adapt_mode {
 	struct mwl8k_cmd_pkt header;
 	__le16 action;
 	__le16 mode;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_set_rateadapt_mode(struct ieee80211_hw *hw, __u16 mode)
 {
@@ -2840,7 +2840,7 @@ static int mwl8k_cmd_set_rateadapt_mode(struct ieee80211_hw *hw, __u16 mode)
 struct mwl8k_cmd_bss_start {
 	struct mwl8k_cmd_pkt header;
 	__le32 enable;
-} __attribute__((packed));
+} __packed;
 
 static int mwl8k_cmd_bss_start(struct ieee80211_hw *hw,
 			       struct ieee80211_vif *vif, int enable)
@@ -2885,7 +2885,7 @@ struct mwl8k_cmd_set_new_stn {
 	__u8 add_qos_info;
 	__u8 is_qos_sta;
 	__le32 fw_sta_ptr;
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_STA_ACTION_ADD		0
 #define MWL8K_STA_ACTION_REMOVE		2
@@ -2978,7 +2978,7 @@ struct ewc_ht_info {
 	__le16	control1;
 	__le16	control2;
 	__le16	control3;
-} __attribute__((packed));
+} __packed;
 
 struct peer_capability_info {
 	/* Peer type - AP vs. STA.  */
@@ -3007,7 +3007,7 @@ struct peer_capability_info {
 	__u8	pad2;
 	__u8	station_id;
 	__le16	amsdu_enabled;
-} __attribute__((packed));
+} __packed;
 
 struct mwl8k_cmd_update_stadb {
 	struct mwl8k_cmd_pkt header;
@@ -3022,7 +3022,7 @@ struct mwl8k_cmd_update_stadb {
 
 	/* Peer info - valid during add/update.  */
 	struct peer_capability_info	peer_info;
-} __attribute__((packed));
+} __packed;
 
 #define MWL8K_STA_DB_MODIFY_ENTRY	1
 #define MWL8K_STA_DB_DEL_ENTRY		2
diff --git a/drivers/net/wireless/orinoco/fw.c b/drivers/net/wireless/orinoco/fw.c
index 3e1947d..259d758 100644
--- a/drivers/net/wireless/orinoco/fw.c
+++ b/drivers/net/wireless/orinoco/fw.c
@@ -49,7 +49,7 @@ struct orinoco_fw_header {
 	__le32 pri_offset;      /* Offset to primary plug data */
 	__le32 compat_offset;   /* Offset to compatibility data*/
 	char signature[0];      /* FW signature length headersize-20 */
-} __attribute__ ((packed));
+} __packed;
 
 /* Check the range of various header entries. Return a pointer to a
  * description of the problem, or NULL if everything checks out. */
diff --git a/drivers/net/wireless/orinoco/hermes.h b/drivers/net/wireless/orinoco/hermes.h
index 9ca34e7..d9f18c1 100644
--- a/drivers/net/wireless/orinoco/hermes.h
+++ b/drivers/net/wireless/orinoco/hermes.h
@@ -205,7 +205,7 @@ struct hermes_tx_descriptor {
 	u8 retry_count;
 	u8 tx_rate;
 	__le16 tx_control;
-} __attribute__ ((packed));
+} __packed;
 
 #define HERMES_TXSTAT_RETRYERR		(0x0001)
 #define HERMES_TXSTAT_AGEDERR		(0x0002)
@@ -254,7 +254,7 @@ struct hermes_tallies_frame {
 	/* Those last are probably not available in very old firmwares */
 	__le16 RxDiscards_WEPICVError;
 	__le16 RxDiscards_WEPExcluded;
-} __attribute__ ((packed));
+} __packed;
 
 /* Grabbed from wlan-ng - Thanks Mark... - Jean II
  * This is the result of a scan inquiry command */
@@ -271,7 +271,7 @@ struct prism2_scan_apinfo {
 	u8 rates[10];		/* Bit rate supported */
 	__le16 proberesp_rate;	/* Data rate of the response frame */
 	__le16 atim;		/* ATIM window time, Kus (hostscan only) */
-} __attribute__ ((packed));
+} __packed;
 
 /* Same stuff for the Lucent/Agere card.
  * Thanks to h1kari <h1kari AT dachb0den.com> - Jean II */
@@ -285,7 +285,7 @@ struct agere_scan_apinfo {
 	/* bits: 0-ess, 1-ibss, 4-privacy [wep] */
 	__le16 essid_len;	/* ESSID length */
 	u8 essid[32];		/* ESSID of the network */
-} __attribute__ ((packed));
+} __packed;
 
 /* Moustafa: Scan structure for Symbol cards */
 struct symbol_scan_apinfo {
@@ -303,7 +303,7 @@ struct symbol_scan_apinfo {
 	__le16 basic_rates;	/* Basic rates bitmask */
 	u8 unknown2[6];		/* Always FF:FF:FF:FF:00:00 */
 	u8 unknown3[8];		/* Always 0, appeared in f/w 3.91-68 */
-} __attribute__ ((packed));
+} __packed;
 
 union hermes_scan_info {
 	struct agere_scan_apinfo	a;
@@ -343,7 +343,7 @@ struct agere_ext_scan_info {
 	__le16	beacon_interval;
 	__le16	capabilities;
 	u8	data[0];
-} __attribute__ ((packed));
+} __packed;
 
 #define HERMES_LINKSTATUS_NOT_CONNECTED   (0x0000)
 #define HERMES_LINKSTATUS_CONNECTED       (0x0001)
@@ -355,7 +355,7 @@ struct agere_ext_scan_info {
 
 struct hermes_linkstatus {
 	__le16 linkstatus;         /* Link status */
-} __attribute__ ((packed));
+} __packed;
 
 struct hermes_response {
 	u16 status, resp0, resp1, resp2;
@@ -365,11 +365,11 @@ struct hermes_response {
 struct hermes_idstring {
 	__le16 len;
 	__le16 val[16];
-} __attribute__ ((packed));
+} __packed;
 
 struct hermes_multicast {
 	u8 addr[HERMES_MAX_MULTICAST][ETH_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 /* Timeouts */
 #define HERMES_BAP_BUSY_TIMEOUT (10000) /* In iterations of ~1us */
diff --git a/drivers/net/wireless/orinoco/hermes_dld.c b/drivers/net/wireless/orinoco/hermes_dld.c
index 6da85e7..55741ca 100644
--- a/drivers/net/wireless/orinoco/hermes_dld.c
+++ b/drivers/net/wireless/orinoco/hermes_dld.c
@@ -65,7 +65,7 @@ struct dblock {
 	__le32 addr;		/* adapter address where to write the block */
 	__le16 len;		/* length of the data only, in bytes */
 	char data[0];		/* data to be written */
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Plug Data References are located in in the image after the last data
@@ -77,7 +77,7 @@ struct pdr {
 	__le32 addr;		/* adapter address where to write the data */
 	__le32 len;		/* expected length of the data, in bytes */
 	char next[0];		/* next PDR starts here */
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Plug Data Items are located in the EEPROM read from the adapter by
@@ -88,7 +88,7 @@ struct pdi {
 	__le16 len;		/* length of ID and data, in words */
 	__le16 id;		/* record ID */
 	char data[0];		/* plug data */
-} __attribute__ ((packed));
+} __packed;
 
 /*** FW data block access functions ***/
 
@@ -317,7 +317,7 @@ static const struct {							\
 	__le16 len;							\
 	__le16 id;							\
 	u8 val[length];							\
-} __attribute__ ((packed)) default_pdr_data_##pid = {			\
+} __packed default_pdr_data_##pid = {			\
 	cpu_to_le16((sizeof(default_pdr_data_##pid)/			\
 				sizeof(__le16)) - 1),			\
 	cpu_to_le16(pid),						\
diff --git a/drivers/net/wireless/orinoco/hw.c b/drivers/net/wireless/orinoco/hw.c
index 6fbd788..077baa8 100644
--- a/drivers/net/wireless/orinoco/hw.c
+++ b/drivers/net/wireless/orinoco/hw.c
@@ -45,7 +45,7 @@ static const struct {
 /* Firmware version encoding */
 struct comp_id {
 	u16 id, variant, major, minor;
-} __attribute__ ((packed));
+} __packed;
 
 static inline fwtype_t determine_firmware_type(struct comp_id *nic_id)
 {
@@ -995,7 +995,7 @@ int __orinoco_hw_set_tkip_key(struct orinoco_private *priv, int key_idx,
 		u8 tx_mic[MIC_KEYLEN];
 		u8 rx_mic[MIC_KEYLEN];
 		u8 tsc[ORINOCO_SEQ_LEN];
-	} __attribute__ ((packed)) buf;
+	} __packed buf;
 	hermes_t *hw = &priv->hw;
 	int ret;
 	int err;
@@ -1326,7 +1326,7 @@ int orinoco_hw_disassociate(struct orinoco_private *priv,
 	struct {
 		u8 addr[ETH_ALEN];
 		__le16 reason_code;
-	} __attribute__ ((packed)) buf;
+	} __packed buf;
 
 	/* Currently only supported by WPA enabled Agere fw */
 	if (!priv->has_wpa)
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index ca71f08..e8e2d0f 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -172,7 +172,7 @@ struct hermes_txexc_data {
 	__le16 frame_ctl;
 	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 /* Rx frame header except compatibility 802.3 header */
 struct hermes_rx_descriptor {
@@ -196,7 +196,7 @@ struct hermes_rx_descriptor {
 
 	/* Data length */
 	__le16 data_len;
-} __attribute__ ((packed));
+} __packed;
 
 struct orinoco_rx_data {
 	struct hermes_rx_descriptor *desc;
@@ -390,7 +390,7 @@ int orinoco_process_xmit_skb(struct sk_buff *skb,
 		struct header_struct {
 			struct ethhdr eth;	/* 802.3 header */
 			u8 encap[6];		/* 802.2 header */
-		} __attribute__ ((packed)) hdr;
+		} __packed hdr;
 		int len = skb->len + sizeof(encaps_hdr) - (2 * ETH_ALEN);
 
 		if (skb_headroom(skb) < ENCAPS_OVERHEAD) {
@@ -1170,7 +1170,7 @@ static void orinoco_join_ap(struct work_struct *work)
 	struct join_req {
 		u8 bssid[ETH_ALEN];
 		__le16 channel;
-	} __attribute__ ((packed)) req;
+	} __packed req;
 	const int atom_len = offsetof(struct prism2_scan_apinfo, atim);
 	struct prism2_scan_apinfo *atom = NULL;
 	int offset = 4;
@@ -1410,7 +1410,7 @@ void __orinoco_ev_info(struct net_device *dev, hermes_t *hw)
 	struct {
 		__le16 len;
 		__le16 type;
-	} __attribute__ ((packed)) info;
+	} __packed info;
 	int len, type;
 	int err;
 
diff --git a/drivers/net/wireless/orinoco/orinoco.h b/drivers/net/wireless/orinoco/orinoco.h
index a6da86e..255710e 100644
--- a/drivers/net/wireless/orinoco/orinoco.h
+++ b/drivers/net/wireless/orinoco/orinoco.h
@@ -32,7 +32,7 @@
 struct orinoco_key {
 	__le16 len;	/* always stored as little-endian */
 	char data[ORINOCO_MAX_KEY_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 #define TKIP_KEYLEN	16
 #define MIC_KEYLEN	8
diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index 78f089b..11536ef 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -90,7 +90,7 @@ struct header_struct {
 	/* SNAP */
 	u8 oui[3];
 	__be16 ethertype;
-} __attribute__ ((packed));
+} __packed;
 
 struct ez_usb_fw {
 	u16 size;
@@ -222,7 +222,7 @@ struct ezusb_packet {
 	__le16 hermes_len;
 	__le16 hermes_rid;
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 /* Table of devices that work or may work with this driver */
 static struct usb_device_id ezusb_table[] = {
diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
index 5775124..9f86a27 100644
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -128,7 +128,7 @@ static struct iw_statistics *orinoco_get_wireless_stats(struct net_device *dev)
 	} else {
 		struct {
 			__le16 qual, signal, noise, unused;
-		} __attribute__ ((packed)) cq;
+		} __packed cq;
 
 		err = HERMES_READ_RECORD(hw, USER_BAP,
 					 HERMES_RID_COMMSQUALITY, &cq);
diff --git a/drivers/net/wireless/p54/net2280.h b/drivers/net/wireless/p54/net2280.h
index 4915d9d..e3ed893 100644
--- a/drivers/net/wireless/p54/net2280.h
+++ b/drivers/net/wireless/p54/net2280.h
@@ -232,7 +232,7 @@ struct net2280_regs {
 #define GPIO2_INTERRUPT						2
 #define GPIO1_INTERRUPT						1
 #define GPIO0_INTERRUPT						0
-} __attribute__ ((packed));
+} __packed;
 
 /* usb control, BAR0 + 0x0080 */
 struct net2280_usb_regs {
@@ -296,7 +296,7 @@ struct net2280_usb_regs {
 #define FORCE_IMMEDIATE						7
 #define OUR_USB_ADDRESS						0
 	__le32			ourconfig;
-} __attribute__ ((packed));
+} __packed;
 
 /* pci control, BAR0 + 0x0100 */
 struct net2280_pci_regs {
@@ -323,7 +323,7 @@ struct net2280_pci_regs {
 #define PCI_ARBITER_CLEAR					2
 #define PCI_EXTERNAL_ARBITER					1
 #define PCI_HOST_MODE						0
-} __attribute__ ((packed));
+} __packed;
 
 /* dma control, BAR0 + 0x0180 ... array of four structs like this,
  * for channels 0..3.  see also struct net2280_dma:  descriptor
@@ -364,7 +364,7 @@ struct net2280_dma_regs {	/* [11.7] */
 	__le32			dmaaddr;
 	__le32			dmadesc;
 	u32			_unused1;
-} __attribute__ ((packed));
+} __packed;
 
 /* dedicated endpoint registers, BAR0 + 0x0200 */
 
@@ -374,7 +374,7 @@ struct net2280_dep_regs {	/* [11.8] */
 	/* offset 0x0204, 0x0214, 0x224, 0x234, 0x244 */
 	__le32			dep_rsp;
 	u32			_unused[2];
-} __attribute__ ((packed));
+} __packed;
 
 /* configurable endpoint registers, BAR0 + 0x0300 ... array of seven structs
  * like this, for ep0 then the configurable endpoints A..F
@@ -437,16 +437,16 @@ struct net2280_ep_regs {	/* [11.9] */
 	__le32			ep_avail;
 	__le32			ep_data;
 	u32			_unused0[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct net2280_reg_write {
 	__le16 port;
 	__le32 addr;
 	__le32 val;
-} __attribute__ ((packed));
+} __packed;
 
 struct net2280_reg_read {
 	__le16 port;
 	__le32 addr;
-} __attribute__ ((packed));
+} __packed;
 #endif /* NET2280_H */
diff --git a/drivers/net/wireless/p54/p54pci.h b/drivers/net/wireless/p54/p54pci.h
index 2feead6..ee9bc62 100644
--- a/drivers/net/wireless/p54/p54pci.h
+++ b/drivers/net/wireless/p54/p54pci.h
@@ -65,7 +65,7 @@ struct p54p_csr {
 	u8 unused_6[1924];
 	u8 cardbus_cis[0x800];
 	u8 direct_mem_win[0x1000];
-} __attribute__ ((packed));
+} __packed;
 
 /* usb backend only needs the register defines above */
 #ifndef P54USB_H
@@ -74,7 +74,7 @@ struct p54p_desc {
 	__le32 device_addr;
 	__le16 len;
 	__le16 flags;
-} __attribute__ ((packed));
+} __packed;
 
 struct p54p_ring_control {
 	__le32 host_idx[4];
@@ -83,7 +83,7 @@ struct p54p_ring_control {
 	struct p54p_desc tx_data[32];
 	struct p54p_desc rx_mgmt[4];
 	struct p54p_desc tx_mgmt[4];
-} __attribute__ ((packed));
+} __packed;
 
 #define P54P_READ(r) (__force __le32)__raw_readl(&priv->map->r)
 #define P54P_WRITE(r, val) __raw_writel((__force u32)(__le32)(val), &priv->map->r)
diff --git a/drivers/net/wireless/p54/p54spi.h b/drivers/net/wireless/p54/p54spi.h
index 7fbe8d8..dfaa62a 100644
--- a/drivers/net/wireless/p54/p54spi.h
+++ b/drivers/net/wireless/p54/p54spi.h
@@ -96,7 +96,7 @@ struct p54s_dma_regs {
 	__le16 cmd;
 	__le16 len;
 	__le32 addr;
-} __attribute__ ((packed));
+} __packed;
 
 struct p54s_tx_info {
 	struct list_head tx_list;
diff --git a/drivers/net/wireless/p54/p54usb.h b/drivers/net/wireless/p54/p54usb.h
index e935b79..ed4034a 100644
--- a/drivers/net/wireless/p54/p54usb.h
+++ b/drivers/net/wireless/p54/p54usb.h
@@ -70,12 +70,12 @@ struct net2280_tx_hdr {
 	__le16 len;
 	__le16 follower;	/* ? */
 	u8 padding[8];
-} __attribute__((packed));
+} __packed;
 
 struct lm87_tx_hdr {
 	__le32 device_addr;
 	__le32 chksum;
-} __attribute__((packed));
+} __packed;
 
 /* Some flags for the isl hardware registers controlling DMA inside the
  * chip */
@@ -103,7 +103,7 @@ struct x2_header {
 	__le32 fw_load_addr;
 	__le32 fw_length;
 	__le32 crc;
-} __attribute__((packed));
+} __packed;
 
 /* pipes 3 and 4 are not used by the driver */
 #define P54U_PIPE_NUMBER 9
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 8d1190c..13730a8 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -2101,7 +2101,7 @@ struct ieee80211_beacon_phdr {
 	u8 timestamp[8];
 	u16 beacon_int;
 	u16 capab_info;
-} __attribute__ ((packed));
+} __packed;
 
 #define WLAN_EID_GENERIC 0xdd
 static u8 wpa_oid[4] = { 0x00, 0x50, 0xf2, 1 };
diff --git a/drivers/net/wireless/prism54/isl_oid.h b/drivers/net/wireless/prism54/isl_oid.h
index b7534c2..59e3125 100644
--- a/drivers/net/wireless/prism54/isl_oid.h
+++ b/drivers/net/wireless/prism54/isl_oid.h
@@ -29,20 +29,20 @@
 struct obj_ssid {
 	u8 length;
 	char octets[33];
-} __attribute__ ((packed));
+} __packed;
 
 struct obj_key {
 	u8 type;		/* dot11_priv_t */
 	u8 length;
 	char key[32];
-} __attribute__ ((packed));
+} __packed;
 
 struct obj_mlme {
 	u8 address[6];
 	u16 id;
 	u16 state;
 	u16 code;
-} __attribute__ ((packed));
+} __packed;
 
 struct obj_mlmeex {
 	u8 address[6];
@@ -51,12 +51,12 @@ struct obj_mlmeex {
 	u16 code;
 	u16 size;
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct obj_buffer {
 	u32 size;
 	u32 addr;		/* 32bit bus address */
-} __attribute__ ((packed));
+} __packed;
 
 struct obj_bss {
 	u8 address[6];
@@ -77,17 +77,17 @@ struct obj_bss {
 	short rates;
 	short basic_rates;
 	int:16;			/* padding */
-} __attribute__ ((packed));
+} __packed;
 
 struct obj_bsslist {
 	u32 nr;
 	struct obj_bss bsslist[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct obj_frequencies {
 	u16 nr;
 	u16 mhz[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct obj_attachment {
 	char type;
@@ -95,7 +95,7 @@ struct obj_attachment {
 	short id;
 	short size;
 	char data[0];
-} __attribute__((packed));
+} __packed;
 
 /*
  * in case everything's ok, the inlined function below will be
diff --git a/drivers/net/wireless/prism54/islpci_eth.h b/drivers/net/wireless/prism54/islpci_eth.h
index 54f9a4b..6ca30a5 100644
--- a/drivers/net/wireless/prism54/islpci_eth.h
+++ b/drivers/net/wireless/prism54/islpci_eth.h
@@ -34,13 +34,13 @@ struct rfmon_header {
 	__le16 unk3;
 	u8 rssi;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct rx_annex_header {
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	struct rfmon_header rfmon;
-} __attribute__ ((packed));
+} __packed;
 
 /* wlan-ng (and hopefully others) AVS header, version one.  Fields in
  * network byte order. */
diff --git a/drivers/net/wireless/prism54/islpci_mgt.h b/drivers/net/wireless/prism54/islpci_mgt.h
index 0b27e50..0db93db 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.h
+++ b/drivers/net/wireless/prism54/islpci_mgt.h
@@ -101,7 +101,7 @@ typedef struct {
 	u8 device_id;
 	u8 flags;
 	u32 length;
-} __attribute__ ((packed))
+} __packed
 pimfor_header_t;
 
 /* A received and interrupt-processed management frame, either for
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 4bd61ee..989b056 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -238,19 +238,19 @@ struct ndis_80211_auth_request {
 	u8 bssid[6];
 	u8 padding[2];
 	__le32 flags;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_pmkid_candidate {
 	u8 bssid[6];
 	u8 padding[2];
 	__le32 flags;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_pmkid_cand_list {
 	__le32 version;
 	__le32 num_candidates;
 	struct ndis_80211_pmkid_candidate candidate_list[0];
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_status_indication {
 	__le32 status_type;
@@ -260,19 +260,19 @@ struct ndis_80211_status_indication {
 		struct ndis_80211_auth_request		auth_request[0];
 		struct ndis_80211_pmkid_cand_list	cand_list;
 	} u;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_ssid {
 	__le32 length;
 	u8 essid[NDIS_802_11_LENGTH_SSID];
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_conf_freq_hop {
 	__le32 length;
 	__le32 hop_pattern;
 	__le32 hop_set;
 	__le32 dwell_time;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_conf {
 	__le32 length;
@@ -280,7 +280,7 @@ struct ndis_80211_conf {
 	__le32 atim_window;
 	__le32 ds_config;
 	struct ndis_80211_conf_freq_hop fh_config;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_bssid_ex {
 	__le32 length;
@@ -295,25 +295,25 @@ struct ndis_80211_bssid_ex {
 	u8 rates[NDIS_802_11_LENGTH_RATES_EX];
 	__le32 ie_length;
 	u8 ies[0];
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_bssid_list_ex {
 	__le32 num_items;
 	struct ndis_80211_bssid_ex bssid[0];
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_fixed_ies {
 	u8 timestamp[8];
 	__le16 beacon_interval;
 	__le16 capabilities;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_wep_key {
 	__le32 size;
 	__le32 index;
 	__le32 length;
 	u8 material[32];
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_key {
 	__le32 size;
@@ -323,14 +323,14 @@ struct ndis_80211_key {
 	u8 padding[6];
 	u8 rsc[8];
 	u8 material[32];
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_remove_key {
 	__le32 size;
 	__le32 index;
 	u8 bssid[6];
 	u8 padding[2];
-} __attribute__((packed));
+} __packed;
 
 struct ndis_config_param {
 	__le32 name_offs;
@@ -338,7 +338,7 @@ struct ndis_config_param {
 	__le32 type;
 	__le32 value_offs;
 	__le32 value_length;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_assoc_info {
 	__le32 length;
@@ -358,12 +358,12 @@ struct ndis_80211_assoc_info {
 	} resp_ie;
 	__le32 resp_ie_length;
 	__le32 offset_resp_ies;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_auth_encr_pair {
 	__le32 auth_mode;
 	__le32 encr_mode;
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_capability {
 	__le32 length;
@@ -371,7 +371,7 @@ struct ndis_80211_capability {
 	__le32 num_pmkids;
 	__le32 num_auth_encr_pair;
 	struct ndis_80211_auth_encr_pair auth_encr_pair[0];
-} __attribute__((packed));
+} __packed;
 
 struct ndis_80211_bssid_info {
 	u8 bssid[6];
diff --git a/drivers/net/wireless/rt2x00/rt2800.h b/drivers/net/wireless/rt2x00/rt2800.h
index 2aa0375..0b17934 100644
--- a/drivers/net/wireless/rt2x00/rt2800.h
+++ b/drivers/net/wireless/rt2x00/rt2800.h
@@ -1370,17 +1370,17 @@
 struct mac_wcid_entry {
 	u8 mac[6];
 	u8 reserved[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct hw_key_entry {
 	u8 key[16];
 	u8 tx_mic[8];
 	u8 rx_mic[8];
-} __attribute__ ((packed));
+} __packed;
 
 struct mac_iveiv_entry {
 	u8 iv[8];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * MAC_WCID_ATTRIBUTE:
diff --git a/drivers/net/wireless/rt2x00/rt61pci.h b/drivers/net/wireless/rt2x00/rt61pci.h
index df80f1a..e2e728a 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.h
+++ b/drivers/net/wireless/rt2x00/rt61pci.h
@@ -153,13 +153,13 @@ struct hw_key_entry {
 	u8 key[16];
 	u8 tx_mic[8];
 	u8 rx_mic[8];
-} __attribute__ ((packed));
+} __packed;
 
 struct hw_pairwise_ta_entry {
 	u8 address[6];
 	u8 cipher;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Other on-chip shared memory space.
diff --git a/drivers/net/wireless/rt2x00/rt73usb.h b/drivers/net/wireless/rt2x00/rt73usb.h
index 7abe7eb..44d5b2b 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.h
+++ b/drivers/net/wireless/rt2x00/rt73usb.h
@@ -108,13 +108,13 @@ struct hw_key_entry {
 	u8 key[16];
 	u8 tx_mic[8];
 	u8 rx_mic[8];
-} __attribute__ ((packed));
+} __packed;
 
 struct hw_pairwise_ta_entry {
 	u8 address[6];
 	u8 cipher;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Since NULL frame won't be that long (256 byte),
diff --git a/drivers/net/wireless/rtl818x/rtl8180.h b/drivers/net/wireless/rtl818x/rtl8180.h
index 4baf0cf..3052331 100644
--- a/drivers/net/wireless/rtl818x/rtl8180.h
+++ b/drivers/net/wireless/rtl818x/rtl8180.h
@@ -36,7 +36,7 @@ struct rtl8180_tx_desc {
 	u8 agc;
 	u8 flags2;
 	u32 reserved[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct rtl8180_rx_desc {
 	__le32 flags;
@@ -45,7 +45,7 @@ struct rtl8180_rx_desc {
 		__le32 rx_buf;
 		__le64 tsft;
 	};
-} __attribute__ ((packed));
+} __packed;
 
 struct rtl8180_tx_ring {
 	struct rtl8180_tx_desc *desc;
diff --git a/drivers/net/wireless/rtl818x/rtl8187.h b/drivers/net/wireless/rtl818x/rtl8187.h
index 6bb3211..9887816 100644
--- a/drivers/net/wireless/rtl818x/rtl8187.h
+++ b/drivers/net/wireless/rtl818x/rtl8187.h
@@ -47,7 +47,7 @@ struct rtl8187_rx_hdr {
 	u8 agc;
 	u8 reserved;
 	__le64 mac_time;
-} __attribute__((packed));
+} __packed;
 
 struct rtl8187b_rx_hdr {
 	__le32 flags;
@@ -59,7 +59,7 @@ struct rtl8187b_rx_hdr {
 	__le16 snr_long2end;
 	s8 pwdb_g12;
 	u8 fot;
-} __attribute__((packed));
+} __packed;
 
 /* {rtl8187,rtl8187b}_tx_info is in skb */
 
@@ -68,7 +68,7 @@ struct rtl8187_tx_hdr {
 	__le16 rts_duration;
 	__le16 len;
 	__le32 retry;
-} __attribute__((packed));
+} __packed;
 
 struct rtl8187b_tx_hdr {
 	__le32 flags;
@@ -80,7 +80,7 @@ struct rtl8187b_tx_hdr {
 	__le32 unused_3;
 	__le32 retry;
 	__le32 unused_4[2];
-} __attribute__((packed));
+} __packed;
 
 enum {
 	DEVICE_RTL8187,
diff --git a/drivers/net/wireless/rtl818x/rtl818x.h b/drivers/net/wireless/rtl818x/rtl818x.h
index 8522490..978519d 100644
--- a/drivers/net/wireless/rtl818x/rtl818x.h
+++ b/drivers/net/wireless/rtl818x/rtl818x.h
@@ -185,7 +185,7 @@ struct rtl818x_csr {
 	u8	reserved_22[4];
 	__le16	TALLY_CNT;
 	u8	TALLY_SEL;
-} __attribute__((packed));
+} __packed;
 
 struct rtl818x_rf_ops {
 	char *name;
diff --git a/drivers/net/wireless/wl12xx/wl1251_acx.h b/drivers/net/wireless/wl12xx/wl1251_acx.h
index 26160c4..842df31 100644
--- a/drivers/net/wireless/wl12xx/wl1251_acx.h
+++ b/drivers/net/wireless/wl12xx/wl1251_acx.h
@@ -60,7 +60,7 @@ struct acx_error_counter {
 	/* the number of missed sequence numbers in the squentially */
 	/* values of frames seq numbers */
 	u32 seq_num_miss;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_revision {
 	struct acx_header header;
@@ -89,7 +89,7 @@ struct acx_revision {
 	 * bits 24 - 31: Chip ID - The WiLink chip ID.
 	 */
 	u32 hw_version;
-} __attribute__ ((packed));
+} __packed;
 
 enum wl1251_psm_mode {
 	/* Active mode */
@@ -111,7 +111,7 @@ struct acx_sleep_auth {
 	/* 2 - ELP mode: Deep / Max sleep*/
 	u8  sleep_auth;
 	u8  padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	HOSTIF_PCI_MASTER_HOST_INDIRECT,
@@ -159,7 +159,7 @@ struct acx_data_path_params {
 	 * complete ring until an interrupt is generated.
 	 */
 	u32 tx_complete_timeout;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct acx_data_path_params_resp {
@@ -180,7 +180,7 @@ struct acx_data_path_params_resp {
 	u32 tx_control_addr;
 
 	u32 tx_complete_addr;
-} __attribute__ ((packed));
+} __packed;
 
 #define TX_MSDU_LIFETIME_MIN       0
 #define TX_MSDU_LIFETIME_MAX       3000
@@ -197,7 +197,7 @@ struct acx_rx_msdu_lifetime {
 	 * firmware discards the MSDU.
 	 */
 	u32 lifetime;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * RX Config Options Table
@@ -285,7 +285,7 @@ struct acx_rx_config {
 
 	u32 config_options;
 	u32 filter_options;
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	QOS_AC_BE = 0,
@@ -325,13 +325,13 @@ struct acx_tx_queue_qos_config {
 
 	/* Lowest memory blocks guaranteed for this queue */
 	u16 low_threshold;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_packet_detection {
 	struct acx_header header;
 
 	u32 threshold;
-} __attribute__ ((packed));
+} __packed;
 
 
 enum acx_slot_type {
@@ -349,7 +349,7 @@ struct acx_slot {
 	u8 wone_index; /* Reserved */
 	u8 slot_time;
 	u8 reserved[6];
-} __attribute__ ((packed));
+} __packed;
 
 
 #define ADDRESS_GROUP_MAX	(8)
@@ -362,7 +362,7 @@ struct acx_dot11_grp_addr_tbl {
 	u8 num_groups;
 	u8 pad[2];
 	u8 mac_table[ADDRESS_GROUP_MAX_LEN];
-} __attribute__ ((packed));
+} __packed;
 
 
 #define  RX_TIMEOUT_PS_POLL_MIN    0
@@ -388,7 +388,7 @@ struct acx_rx_timeout {
 	 * from an UPSD enabled queue.
 	 */
 	u16 upsd_timeout;
-} __attribute__ ((packed));
+} __packed;
 
 #define RTS_THRESHOLD_MIN              0
 #define RTS_THRESHOLD_MAX              4096
@@ -399,7 +399,7 @@ struct acx_rts_threshold {
 
 	u16 threshold;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_beacon_filter_option {
 	struct acx_header header;
@@ -415,7 +415,7 @@ struct acx_beacon_filter_option {
 	 */
 	u8 max_num_beacons;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * ACXBeaconFilterEntry (not 221)
@@ -461,7 +461,7 @@ struct acx_beacon_filter_ie_table {
 	u8 num_ie;
 	u8 table[BEACON_FILTER_TABLE_MAX_SIZE];
 	u8 pad[3];
-} __attribute__ ((packed));
+} __packed;
 
 #define SYNCH_FAIL_DEFAULT_THRESHOLD    10     /* number of beacons */
 #define NO_BEACON_DEFAULT_TIMEOUT       (500) /* in microseconds */
@@ -494,7 +494,7 @@ struct acx_bt_wlan_coex {
 	 */
 	u8 enable;
 	u8 pad[3];
-} __attribute__ ((packed));
+} __packed;
 
 #define PTA_ANTENNA_TYPE_DEF		  (0)
 #define PTA_BT_HP_MAXTIME_DEF		  (2000)
@@ -648,7 +648,7 @@ struct acx_bt_wlan_coex_param {
 
 	/* range: 0 - 20  default: 1 */
 	u8 bt_hp_respected_num;
-} __attribute__ ((packed));
+} __packed;
 
 #define CCA_THRSH_ENABLE_ENERGY_D       0x140A
 #define CCA_THRSH_DISABLE_ENERGY_D      0xFFEF
@@ -660,7 +660,7 @@ struct acx_energy_detection {
 	u16 rx_cca_threshold;
 	u8 tx_energy_detection;
 	u8 pad;
-} __attribute__ ((packed));
+} __packed;
 
 #define BCN_RX_TIMEOUT_DEF_VALUE        10000
 #define BROADCAST_RX_TIMEOUT_DEF_VALUE  20000
@@ -679,14 +679,14 @@ struct acx_beacon_broadcast {
 	/* Consecutive PS Poll failures before updating the host */
 	u8 ps_poll_threshold;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_event_mask {
 	struct acx_header header;
 
 	u32 event_mask;
 	u32 high_event_mask; /* Unused */
-} __attribute__ ((packed));
+} __packed;
 
 #define CFG_RX_FCS		BIT(2)
 #define CFG_RX_ALL_GOOD		BIT(3)
@@ -729,7 +729,7 @@ struct acx_fw_gen_frame_rates {
 	u8 tx_ctrl_frame_mod; /* CCK_* or PBCC_* */
 	u8 tx_mgt_frame_rate;
 	u8 tx_mgt_frame_mod;
-} __attribute__ ((packed));
+} __packed;
 
 /* STA MAC */
 struct acx_dot11_station_id {
@@ -737,28 +737,28 @@ struct acx_dot11_station_id {
 
 	u8 mac[ETH_ALEN];
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_feature_config {
 	struct acx_header header;
 
 	u32 options;
 	u32 data_flow_options;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_current_tx_power {
 	struct acx_header header;
 
 	u8  current_tx_power;
 	u8  padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_dot11_default_key {
 	struct acx_header header;
 
 	u8 id;
 	u8 pad[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_tsf_info {
 	struct acx_header header;
@@ -769,7 +769,7 @@ struct acx_tsf_info {
 	u32 last_TBTT_lsb;
 	u8 last_dtim_count;
 	u8 pad[3];
-} __attribute__ ((packed));
+} __packed;
 
 enum acx_wake_up_event {
 	WAKE_UP_EVENT_BEACON_BITMAP	= 0x01, /* Wake on every Beacon*/
@@ -785,7 +785,7 @@ struct acx_wake_up_condition {
 	u8 wake_up_event; /* Only one bit can be set */
 	u8 listen_interval;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_aid {
 	struct acx_header header;
@@ -795,7 +795,7 @@ struct acx_aid {
 	 */
 	u16 aid;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 enum acx_preamble_type {
 	ACX_PREAMBLE_LONG = 0,
@@ -811,7 +811,7 @@ struct acx_preamble {
 	 */
 	u8 preamble;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 enum acx_ctsprotect_type {
 	CTSPROTECT_DISABLE = 0,
@@ -822,11 +822,11 @@ struct acx_ctsprotect {
 	struct acx_header header;
 	u8 ctsprotect;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_tx_statistics {
 	u32 internal_desc_overflow;
-}  __attribute__ ((packed));
+}  __packed;
 
 struct acx_rx_statistics {
 	u32 out_of_mem;
@@ -837,14 +837,14 @@ struct acx_rx_statistics {
 	u32 xfr_hint_trig;
 	u32 path_reset;
 	u32 reset_counter;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_dma_statistics {
 	u32 rx_requested;
 	u32 rx_errors;
 	u32 tx_requested;
 	u32 tx_errors;
-}  __attribute__ ((packed));
+}  __packed;
 
 struct acx_isr_statistics {
 	/* host command complete */
@@ -903,7 +903,7 @@ struct acx_isr_statistics {
 
 	/* (INT_STS_ND & INT_TRIG_LOW_RSSI) */
 	u32 low_rssi;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_wep_statistics {
 	/* WEP address keys configured */
@@ -925,7 +925,7 @@ struct acx_wep_statistics {
 
 	/* WEP decrypt interrupts */
 	u32 interrupt;
-} __attribute__ ((packed));
+} __packed;
 
 #define ACX_MISSED_BEACONS_SPREAD 10
 
@@ -985,12 +985,12 @@ struct acx_pwr_statistics {
 
 	/* the number of beacons in awake mode */
 	u32 rcvd_awake_beacons;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_mic_statistics {
 	u32 rx_pkts;
 	u32 calc_failure;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_aes_statistics {
 	u32 encrypt_fail;
@@ -999,7 +999,7 @@ struct acx_aes_statistics {
 	u32 decrypt_packets;
 	u32 encrypt_interrupt;
 	u32 decrypt_interrupt;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_event_statistics {
 	u32 heart_beat;
@@ -1010,7 +1010,7 @@ struct acx_event_statistics {
 	u32 oom_late;
 	u32 phy_transmit_error;
 	u32 tx_stuck;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_ps_statistics {
 	u32 pspoll_timeouts;
@@ -1020,7 +1020,7 @@ struct acx_ps_statistics {
 	u32 pspoll_max_apturn;
 	u32 pspoll_utilization;
 	u32 upsd_utilization;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_rxpipe_statistics {
 	u32 rx_prep_beacon_drop;
@@ -1028,7 +1028,7 @@ struct acx_rxpipe_statistics {
 	u32 beacon_buffer_thres_host_int_trig_rx_data;
 	u32 missed_beacon_host_int_trig_rx_data;
 	u32 tx_xfr_host_int_trig_rx_data;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_statistics {
 	struct acx_header header;
@@ -1044,7 +1044,7 @@ struct acx_statistics {
 	struct acx_event_statistics event;
 	struct acx_ps_statistics ps;
 	struct acx_rxpipe_statistics rxpipe;
-} __attribute__ ((packed));
+} __packed;
 
 #define ACX_MAX_RATE_CLASSES       8
 #define ACX_RATE_MASK_UNSPECIFIED  0
@@ -1063,7 +1063,7 @@ struct acx_rate_policy {
 
 	u32 rate_class_cnt;
 	struct acx_rate_class rate_class[ACX_MAX_RATE_CLASSES];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1251_acx_memory {
 	__le16 num_stations; /* number of STAs to be supported. */
@@ -1082,7 +1082,7 @@ struct wl1251_acx_memory {
 	u8 tx_min_mem_block_num;
 	u8 num_ssid_profiles;
 	__le16 debug_buffer_size;
-} __attribute__ ((packed));
+} __packed;
 
 
 #define ACX_RX_DESC_MIN                1
@@ -1094,7 +1094,7 @@ struct wl1251_acx_rx_queue_config {
 	u8 type;
 	u8 priority;
 	__le32 dma_address;
-} __attribute__ ((packed));
+} __packed;
 
 #define ACX_TX_DESC_MIN                1
 #define ACX_TX_DESC_MAX                127
@@ -1103,7 +1103,7 @@ struct wl1251_acx_tx_queue_config {
     u8 num_descs;
     u8 pad[2];
     u8 attributes;
-} __attribute__ ((packed));
+} __packed;
 
 #define MAX_TX_QUEUE_CONFIGS 5
 #define MAX_TX_QUEUES 4
@@ -1113,7 +1113,7 @@ struct wl1251_acx_config_memory {
 	struct wl1251_acx_memory mem_config;
 	struct wl1251_acx_rx_queue_config rx_queue_config;
 	struct wl1251_acx_tx_queue_config tx_queue_config[MAX_TX_QUEUE_CONFIGS];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1251_acx_mem_map {
 	struct acx_header header;
@@ -1147,7 +1147,7 @@ struct wl1251_acx_mem_map {
 
 	/* Number of blocks FW allocated for RX packets */
 	u32 num_rx_mem_blocks;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct wl1251_acx_wr_tbtt_and_dtim {
@@ -1164,7 +1164,7 @@ struct wl1251_acx_wr_tbtt_and_dtim {
 	*/
 	u8  dtim;
 	u8  padding;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1251_acx_ac_cfg {
 	struct acx_header header;
@@ -1194,7 +1194,7 @@ struct wl1251_acx_ac_cfg {
 
 	/* The TX Op Limit (in microseconds) for the access class. */
 	u16 txop_limit;
-} __attribute__ ((packed));
+} __packed;
 
 
 enum wl1251_acx_channel_type {
@@ -1245,7 +1245,7 @@ struct wl1251_acx_tid_cfg {
 
 	/* not supported */
 	u32 apsdconf[2];
-} __attribute__ ((packed));
+} __packed;
 
 /*************************************************************************
 
diff --git a/drivers/net/wireless/wl12xx/wl1251_cmd.h b/drivers/net/wireless/wl12xx/wl1251_cmd.h
index 4ad67ca..7e70dd5 100644
--- a/drivers/net/wireless/wl12xx/wl1251_cmd.h
+++ b/drivers/net/wireless/wl12xx/wl1251_cmd.h
@@ -106,7 +106,7 @@ struct wl1251_cmd_header {
 	u16 status;
 	/* payload */
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct  wl1251_command {
 	struct wl1251_cmd_header header;
@@ -201,7 +201,7 @@ struct wl1251_scan_parameters {
 	u8 ssid_len;
 	u8 ssid[32];
 
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1251_scan_ch_parameters {
 	u32 min_duration; /* in TU */
@@ -218,7 +218,7 @@ struct wl1251_scan_ch_parameters {
 	u8 tx_power_att;
 	u8 channel;
 	u8 pad[3];
-} __attribute__ ((packed));
+} __packed;
 
 /* SCAN parameters */
 #define SCAN_MAX_NUM_OF_CHANNELS 16
@@ -228,7 +228,7 @@ struct wl1251_cmd_scan {
 
 	struct wl1251_scan_parameters params;
 	struct wl1251_scan_ch_parameters channels[SCAN_MAX_NUM_OF_CHANNELS];
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	BSS_TYPE_IBSS = 0,
@@ -276,14 +276,14 @@ struct cmd_join {
 	u8 tx_mgt_frame_rate; /* OBSOLETE */
 	u8 tx_mgt_frame_mod;  /* OBSOLETE */
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_enabledisable_path {
 	struct wl1251_cmd_header header;
 
 	u8 channel;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 #define WL1251_MAX_TEMPLATE_SIZE 300
 
@@ -292,7 +292,7 @@ struct wl1251_cmd_packet_template {
 
 	__le16 size;
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 #define TIM_ELE_ID    5
 #define PARTIAL_VBM_MAX    251
@@ -304,7 +304,7 @@ struct wl1251_tim {
 	u8 dtim_period;
 	u8 bitmap_ctrl;
 	u8 pvb_field[PARTIAL_VBM_MAX]; /* Partial Virtual Bitmap */
-} __attribute__ ((packed));
+} __packed;
 
 /* Virtual Bit Map update */
 struct wl1251_cmd_vbm_update {
@@ -312,7 +312,7 @@ struct wl1251_cmd_vbm_update {
 	__le16 len;
 	u8  padding[2];
 	struct wl1251_tim tim;
-} __attribute__ ((packed));
+} __packed;
 
 enum wl1251_cmd_ps_mode {
 	STATION_ACTIVE_MODE,
@@ -333,7 +333,7 @@ struct wl1251_cmd_ps_params {
 	u8 hang_over_period;
 	u16 null_data_rate;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1251_cmd_trigger_scan_to {
 	struct wl1251_cmd_header header;
@@ -411,7 +411,7 @@ struct wl1251_cmd_set_keys {
 	u8 key[MAX_KEY_SIZE];
 	u16 ac_seq_num16[NUM_ACCESS_CATEGORIES_COPY];
 	u32 ac_seq_num32[NUM_ACCESS_CATEGORIES_COPY];
-} __attribute__ ((packed));
+} __packed;
 
 
 #endif /* __WL1251_CMD_H__ */
diff --git a/drivers/net/wireless/wl12xx/wl1251_event.h b/drivers/net/wireless/wl12xx/wl1251_event.h
index be0ac54..f48a2b6 100644
--- a/drivers/net/wireless/wl12xx/wl1251_event.h
+++ b/drivers/net/wireless/wl12xx/wl1251_event.h
@@ -82,7 +82,7 @@ struct event_debug_report {
 	u32 report_1;
 	u32 report_2;
 	u32 report_3;
-} __attribute__ ((packed));
+} __packed;
 
 struct event_mailbox {
 	u32 events_vector;
@@ -112,7 +112,7 @@ struct event_mailbox {
 	struct event_debug_report report;
 	u8 average_snr_level;
 	u8 padding[19];
-} __attribute__ ((packed));
+} __packed;
 
 int wl1251_event_unmask(struct wl1251 *wl);
 void wl1251_event_mbox_config(struct wl1251 *wl);
diff --git a/drivers/net/wireless/wl12xx/wl1251_rx.h b/drivers/net/wireless/wl12xx/wl1251_rx.h
index 563a3fd..da4e534 100644
--- a/drivers/net/wireless/wl12xx/wl1251_rx.h
+++ b/drivers/net/wireless/wl12xx/wl1251_rx.h
@@ -117,7 +117,7 @@ struct wl1251_rx_descriptor {
 	s8 rssi; /* in dB */
 	u8 rcpi; /* in dB */
 	u8 snr; /* in dB */
-} __attribute__ ((packed));
+} __packed;
 
 void wl1251_rx(struct wl1251 *wl);
 
diff --git a/drivers/net/wireless/wl12xx/wl1251_tx.h b/drivers/net/wireless/wl12xx/wl1251_tx.h
index 55856c6..65c4be8 100644
--- a/drivers/net/wireless/wl12xx/wl1251_tx.h
+++ b/drivers/net/wireless/wl12xx/wl1251_tx.h
@@ -109,7 +109,7 @@ struct tx_control {
 	unsigned xfer_pad:1;
 
 	unsigned reserved:7;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct tx_double_buffer_desc {
@@ -156,7 +156,7 @@ struct tx_double_buffer_desc {
 	u8 num_mem_blocks;
 
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	TX_SUCCESS              = 0,
@@ -208,7 +208,7 @@ struct tx_result {
 
 	/* See done_1 */
 	u8 done_2;
-} __attribute__ ((packed));
+} __packed;
 
 static inline int wl1251_tx_get_queue(int queue)
 {
diff --git a/drivers/net/wireless/wl12xx/wl1271.h b/drivers/net/wireless/wl12xx/wl1271.h
index 6f1b6b5..9af1464 100644
--- a/drivers/net/wireless/wl12xx/wl1271.h
+++ b/drivers/net/wireless/wl12xx/wl1271.h
@@ -141,7 +141,7 @@ struct wl1271_nvs_file {
 	u8 dyn_radio_params[WL1271_NVS_FEM_COUNT]
 			   [WL1271_NVS_DYN_RADIO_PARAMS_SIZE_PADDED];
 	u8 ini_spare[WL1271_NVS_INI_SPARE_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * Enable/disable 802.11a support for WL1273
@@ -317,7 +317,7 @@ struct wl1271_fw_status {
 	__le32 tx_released_blks[NUM_TX_QUEUES];
 	__le32 fw_localtime;
 	__le32 padding[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_rx_mem_pool_addr {
 	u32 addr;
diff --git a/drivers/net/wireless/wl12xx/wl1271_acx.h b/drivers/net/wireless/wl12xx/wl1271_acx.h
index 420e7e2..4c87e60 100644
--- a/drivers/net/wireless/wl12xx/wl1271_acx.h
+++ b/drivers/net/wireless/wl12xx/wl1271_acx.h
@@ -75,7 +75,7 @@ struct acx_header {
 
 	/* payload length (not including headers */
 	__le16 len;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_error_counter {
 	struct acx_header header;
@@ -98,7 +98,7 @@ struct acx_error_counter {
 	/* the number of missed sequence numbers in the squentially */
 	/* values of frames seq numbers */
 	__le32 seq_num_miss;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_revision {
 	struct acx_header header;
@@ -127,7 +127,7 @@ struct acx_revision {
 	 * bits 24 - 31: Chip ID - The WiLink chip ID.
 	 */
 	__le32 hw_version;
-} __attribute__ ((packed));
+} __packed;
 
 enum wl1271_psm_mode {
 	/* Active mode */
@@ -149,7 +149,7 @@ struct acx_sleep_auth {
 	/* 2 - ELP mode: Deep / Max sleep*/
 	u8  sleep_auth;
 	u8  padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	HOSTIF_PCI_MASTER_HOST_INDIRECT,
@@ -187,7 +187,7 @@ struct acx_rx_msdu_lifetime {
 	 * firmware discards the MSDU.
 	 */
 	__le32 lifetime;
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * RX Config Options Table
@@ -275,13 +275,13 @@ struct acx_rx_config {
 
 	__le32 config_options;
 	__le32 filter_options;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_packet_detection {
 	struct acx_header header;
 
 	__le32 threshold;
-} __attribute__ ((packed));
+} __packed;
 
 
 enum acx_slot_type {
@@ -299,7 +299,7 @@ struct acx_slot {
 	u8 wone_index; /* Reserved */
 	u8 slot_time;
 	u8 reserved[6];
-} __attribute__ ((packed));
+} __packed;
 
 
 #define ACX_MC_ADDRESS_GROUP_MAX	(8)
@@ -312,21 +312,21 @@ struct acx_dot11_grp_addr_tbl {
 	u8 num_groups;
 	u8 pad[2];
 	u8 mac_table[ADDRESS_GROUP_MAX_LEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_rx_timeout {
 	struct acx_header header;
 
 	__le16 ps_poll_timeout;
 	__le16 upsd_timeout;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_rts_threshold {
 	struct acx_header header;
 
 	__le16 threshold;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_beacon_filter_option {
 	struct acx_header header;
@@ -342,7 +342,7 @@ struct acx_beacon_filter_option {
 	 */
 	u8 max_num_beacons;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * ACXBeaconFilterEntry (not 221)
@@ -383,21 +383,21 @@ struct acx_beacon_filter_ie_table {
 	u8 num_ie;
 	u8 pad[3];
 	u8 table[BEACON_FILTER_TABLE_MAX_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_conn_monit_params {
        struct acx_header header;
 
        __le32 synch_fail_thold; /* number of beacons missed */
        __le32 bss_lose_timeout; /* number of TU's from synch fail */
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_bt_wlan_coex {
 	struct acx_header header;
 
 	u8 enable;
 	u8 pad[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_bt_wlan_coex_param {
 	struct acx_header header;
@@ -405,7 +405,7 @@ struct acx_bt_wlan_coex_param {
 	__le32 params[CONF_SG_PARAMS_MAX];
 	u8 param_idx;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_dco_itrim_params {
 	struct acx_header header;
@@ -413,7 +413,7 @@ struct acx_dco_itrim_params {
 	u8 enable;
 	u8 padding[3];
 	__le32 timeout;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_energy_detection {
 	struct acx_header header;
@@ -422,7 +422,7 @@ struct acx_energy_detection {
 	__le16 rx_cca_threshold;
 	u8 tx_energy_detection;
 	u8 pad;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_beacon_broadcast {
 	struct acx_header header;
@@ -436,14 +436,14 @@ struct acx_beacon_broadcast {
 	/* Consecutive PS Poll failures before updating the host */
 	u8 ps_poll_threshold;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_event_mask {
 	struct acx_header header;
 
 	__le32 event_mask;
 	__le32 high_event_mask; /* Unused */
-} __attribute__ ((packed));
+} __packed;
 
 #define CFG_RX_FCS		BIT(2)
 #define CFG_RX_ALL_GOOD		BIT(3)
@@ -488,14 +488,14 @@ struct acx_feature_config {
 
 	__le32 options;
 	__le32 data_flow_options;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_current_tx_power {
 	struct acx_header header;
 
 	u8  current_tx_power;
 	u8  padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_wake_up_condition {
 	struct acx_header header;
@@ -503,7 +503,7 @@ struct acx_wake_up_condition {
 	u8 wake_up_event; /* Only one bit can be set */
 	u8 listen_interval;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_aid {
 	struct acx_header header;
@@ -513,7 +513,7 @@ struct acx_aid {
 	 */
 	__le16 aid;
 	u8 pad[2];
-} __attribute__ ((packed));
+} __packed;
 
 enum acx_preamble_type {
 	ACX_PREAMBLE_LONG = 0,
@@ -529,7 +529,7 @@ struct acx_preamble {
 	 */
 	u8 preamble;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 enum acx_ctsprotect_type {
 	CTSPROTECT_DISABLE = 0,
@@ -540,11 +540,11 @@ struct acx_ctsprotect {
 	struct acx_header header;
 	u8 ctsprotect;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_tx_statistics {
 	__le32 internal_desc_overflow;
-}  __attribute__ ((packed));
+}  __packed;
 
 struct acx_rx_statistics {
 	__le32 out_of_mem;
@@ -555,14 +555,14 @@ struct acx_rx_statistics {
 	__le32 xfr_hint_trig;
 	__le32 path_reset;
 	__le32 reset_counter;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_dma_statistics {
 	__le32 rx_requested;
 	__le32 rx_errors;
 	__le32 tx_requested;
 	__le32 tx_errors;
-}  __attribute__ ((packed));
+}  __packed;
 
 struct acx_isr_statistics {
 	/* host command complete */
@@ -621,7 +621,7 @@ struct acx_isr_statistics {
 
 	/* (INT_STS_ND & INT_TRIG_LOW_RSSI) */
 	__le32 low_rssi;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_wep_statistics {
 	/* WEP address keys configured */
@@ -643,7 +643,7 @@ struct acx_wep_statistics {
 
 	/* WEP decrypt interrupts */
 	__le32 interrupt;
-} __attribute__ ((packed));
+} __packed;
 
 #define ACX_MISSED_BEACONS_SPREAD 10
 
@@ -703,12 +703,12 @@ struct acx_pwr_statistics {
 
 	/* the number of beacons in awake mode */
 	__le32 rcvd_awake_beacons;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_mic_statistics {
 	__le32 rx_pkts;
 	__le32 calc_failure;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_aes_statistics {
 	__le32 encrypt_fail;
@@ -717,7 +717,7 @@ struct acx_aes_statistics {
 	__le32 decrypt_packets;
 	__le32 encrypt_interrupt;
 	__le32 decrypt_interrupt;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_event_statistics {
 	__le32 heart_beat;
@@ -728,7 +728,7 @@ struct acx_event_statistics {
 	__le32 oom_late;
 	__le32 phy_transmit_error;
 	__le32 tx_stuck;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_ps_statistics {
 	__le32 pspoll_timeouts;
@@ -738,7 +738,7 @@ struct acx_ps_statistics {
 	__le32 pspoll_max_apturn;
 	__le32 pspoll_utilization;
 	__le32 upsd_utilization;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_rxpipe_statistics {
 	__le32 rx_prep_beacon_drop;
@@ -746,7 +746,7 @@ struct acx_rxpipe_statistics {
 	__le32 beacon_buffer_thres_host_int_trig_rx_data;
 	__le32 missed_beacon_host_int_trig_rx_data;
 	__le32 tx_xfr_host_int_trig_rx_data;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_statistics {
 	struct acx_header header;
@@ -762,7 +762,7 @@ struct acx_statistics {
 	struct acx_event_statistics event;
 	struct acx_ps_statistics ps;
 	struct acx_rxpipe_statistics rxpipe;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_rate_class {
 	__le32 enabled_rates;
@@ -780,7 +780,7 @@ struct acx_rate_policy {
 
 	__le32 rate_class_cnt;
 	struct acx_rate_class rate_class[CONF_TX_MAX_RATE_CLASSES];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_ac_cfg {
 	struct acx_header header;
@@ -790,7 +790,7 @@ struct acx_ac_cfg {
 	u8 aifsn;
 	u8 reserved;
 	__le16 tx_op_limit;
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_tid_config {
 	struct acx_header header;
@@ -801,19 +801,19 @@ struct acx_tid_config {
 	u8 ack_policy;
 	u8 padding[3];
 	__le32 apsd_conf[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_frag_threshold {
 	struct acx_header header;
 	__le16 frag_threshold;
 	u8 padding[2];
-} __attribute__ ((packed));
+} __packed;
 
 struct acx_tx_config_options {
 	struct acx_header header;
 	__le16 tx_compl_timeout;     /* msec */
 	__le16 tx_compl_threshold;   /* number of packets */
-} __attribute__ ((packed));
+} __packed;
 
 #define ACX_RX_MEM_BLOCKS     70
 #define ACX_TX_MIN_MEM_BLOCKS 40
@@ -828,7 +828,7 @@ struct wl1271_acx_config_memory {
 	u8 num_stations;
 	u8 num_ssid_profiles;
 	__le32 total_tx_descriptors;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_acx_mem_map {
 	struct acx_header header;
@@ -872,7 +872,7 @@ struct wl1271_acx_mem_map {
 	u8 *rx_cbuf;
 	__le32 rx_ctrl;
 	__le32 tx_ctrl;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_acx_rx_config_opt {
 	struct acx_header header;
@@ -882,7 +882,7 @@ struct wl1271_acx_rx_config_opt {
 	__le16 timeout;
 	u8 queue_type;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct wl1271_acx_bet_enable {
@@ -891,7 +891,7 @@ struct wl1271_acx_bet_enable {
 	u8 enable;
 	u8 max_consecutive;
 	u8 padding[2];
-} __attribute__ ((packed));
+} __packed;
 
 #define ACX_IPV4_VERSION 4
 #define ACX_IPV6_VERSION 6
@@ -905,7 +905,7 @@ struct wl1271_acx_arp_filter {
 			       requests directed to this IP address will pass
 			       through. For IPv4, the first four bytes are
 			       used. */
-} __attribute__((packed));
+} __packed;
 
 struct wl1271_acx_pm_config {
 	struct acx_header header;
@@ -913,14 +913,14 @@ struct wl1271_acx_pm_config {
 	__le32 host_clk_settling_time;
 	u8 host_fast_wakeup_support;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_acx_keep_alive_mode {
 	struct acx_header header;
 
 	u8 enabled;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	ACX_KEEP_ALIVE_NO_TX = 0,
@@ -940,7 +940,7 @@ struct wl1271_acx_keep_alive_config {
 	u8 tpl_validation;
 	u8 trigger;
 	u8 padding;
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	WL1271_ACX_TRIG_TYPE_LEVEL = 0,
diff --git a/drivers/net/wireless/wl12xx/wl1271_cmd.h b/drivers/net/wireless/wl12xx/wl1271_cmd.h
index f2820b4..d88faf9 100644
--- a/drivers/net/wireless/wl12xx/wl1271_cmd.h
+++ b/drivers/net/wireless/wl12xx/wl1271_cmd.h
@@ -136,14 +136,14 @@ struct wl1271_cmd_header {
 	__le16 status;
 	/* payload */
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 #define WL1271_CMD_MAX_PARAMS 572
 
 struct wl1271_command {
 	struct wl1271_cmd_header header;
 	u8  parameters[WL1271_CMD_MAX_PARAMS];
-} __attribute__ ((packed));
+} __packed;
 
 enum {
 	CMD_MAILBOX_IDLE		=  0,
@@ -196,7 +196,7 @@ struct cmd_read_write_memory {
 	   of this field is the Host in WRITE command or the Wilink in READ
 	   command. */
 	u8 value[MAX_READ_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 #define CMDMBOX_HEADER_LEN 4
 #define CMDMBOX_INFO_ELEM_HEADER_LEN 4
@@ -243,14 +243,14 @@ struct wl1271_cmd_join {
 	u8 ssid[IW_ESSID_MAX_SIZE];
 	u8 ctrl; /* JOIN_CMD_CTRL_* */
 	u8 reserved[3];
-} __attribute__ ((packed));
+} __packed;
 
 struct cmd_enabledisable_path {
 	struct wl1271_cmd_header header;
 
 	u8 channel;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 #define WL1271_RATE_AUTOMATIC  0
 
@@ -266,7 +266,7 @@ struct wl1271_cmd_template_set {
 	u8 aflags;
 	u8 reserved;
 	u8 template_data[WL1271_CMD_TEMPL_MAX_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 #define TIM_ELE_ID    5
 #define PARTIAL_VBM_MAX    251
@@ -278,7 +278,7 @@ struct wl1271_tim {
 	u8 dtim_period;
 	u8 bitmap_ctrl;
 	u8 pvb_field[PARTIAL_VBM_MAX]; /* Partial Virtual Bitmap */
-} __attribute__ ((packed));
+} __packed;
 
 enum wl1271_cmd_ps_mode {
 	STATION_ACTIVE_MODE,
@@ -298,7 +298,7 @@ struct wl1271_cmd_ps_params {
 	  */
 	u8 hang_over_period;
 	__le32 null_data_rate;
-} __attribute__ ((packed));
+} __packed;
 
 /* HW encryption keys */
 #define NUM_ACCESS_CATEGORIES_COPY 4
@@ -348,7 +348,7 @@ struct wl1271_cmd_set_keys {
 	u8 key[MAX_KEY_SIZE];
 	__le16 ac_seq_num16[NUM_ACCESS_CATEGORIES_COPY];
 	__le32 ac_seq_num32[NUM_ACCESS_CATEGORIES_COPY];
-} __attribute__ ((packed));
+} __packed;
 
 
 #define WL1271_SCAN_MAX_CHANNELS       24
@@ -385,7 +385,7 @@ struct basic_scan_params {
 	u8 use_ssid_list;
 	u8 scan_tag;
 	u8 padding2;
-} __attribute__ ((packed));
+} __packed;
 
 struct basic_scan_channel_params {
 	/* Duration in TU to wait for frames on a channel for active scan */
@@ -400,25 +400,25 @@ struct basic_scan_channel_params {
 	u8 dfs_candidate;
 	u8 activity_detected;
 	u8 pad;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_cmd_scan {
 	struct wl1271_cmd_header header;
 
 	struct basic_scan_params params;
 	struct basic_scan_channel_params channels[WL1271_SCAN_MAX_CHANNELS];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_cmd_trigger_scan_to {
 	struct wl1271_cmd_header header;
 
 	__le32 timeout;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_cmd_test_header {
 	u8 id;
 	u8 padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 enum wl1271_channel_tune_bands {
 	WL1271_CHANNEL_TUNE_BAND_2_4,
@@ -441,7 +441,7 @@ struct wl1271_general_parms_cmd {
 
 	u8 params[WL1271_NVS_GENERAL_PARAMS_SIZE];
 	s8 reserved[23];
-} __attribute__ ((packed));
+} __packed;
 
 #define WL1271_STAT_RADIO_PARAMS_5_SIZE    29
 #define WL1271_DYN_RADIO_PARAMS_5_SIZE    104
@@ -457,7 +457,7 @@ struct wl1271_radio_parms_cmd {
 	u8 dyn_radio_params[WL1271_NVS_DYN_RADIO_PARAMS_SIZE];
 	u8 reserved;
 	u8 dyn_radio_params_5[WL1271_DYN_RADIO_PARAMS_5_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_cmd_cal_channel_tune {
 	struct wl1271_cmd_header header;
@@ -468,7 +468,7 @@ struct wl1271_cmd_cal_channel_tune {
 	u8 channel;
 
 	__le16 radio_status;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_cmd_cal_update_ref_point {
 	struct wl1271_cmd_header header;
@@ -479,7 +479,7 @@ struct wl1271_cmd_cal_update_ref_point {
 	__le32 ref_detector;
 	u8  sub_band;
 	u8  padding[3];
-} __attribute__ ((packed));
+} __packed;
 
 #define MAX_TLV_LENGTH         400
 #define	MAX_NVS_VERSION_LENGTH 12
@@ -501,7 +501,7 @@ struct wl1271_cmd_cal_p2g {
 
 	u8  sub_band_mask;
 	u8  padding2;
-} __attribute__ ((packed));
+} __packed;
 
 
 /*
@@ -529,6 +529,6 @@ struct wl1271_cmd_disconnect {
 	u8  type;
 
 	u8  padding;
-} __attribute__ ((packed));
+} __packed;
 
 #endif /* __WL1271_CMD_H__ */
diff --git a/drivers/net/wireless/wl12xx/wl1271_event.h b/drivers/net/wireless/wl12xx/wl1271_event.h
index 5837100..43d5aea 100644
--- a/drivers/net/wireless/wl12xx/wl1271_event.h
+++ b/drivers/net/wireless/wl12xx/wl1271_event.h
@@ -85,7 +85,7 @@ struct event_debug_report {
 	__le32 report_1;
 	__le32 report_2;
 	__le32 report_3;
-} __attribute__ ((packed));
+} __packed;
 
 #define NUM_OF_RSSI_SNR_TRIGGERS 8
 
@@ -116,7 +116,7 @@ struct event_mailbox {
 	u8 ps_status;
 
 	u8 reserved_5[29];
-} __attribute__ ((packed));
+} __packed;
 
 int wl1271_event_unmask(struct wl1271 *wl);
 void wl1271_event_mbox_config(struct wl1271 *wl);
diff --git a/drivers/net/wireless/wl12xx/wl1271_rx.h b/drivers/net/wireless/wl12xx/wl1271_rx.h
index b89be47..13a2323 100644
--- a/drivers/net/wireless/wl12xx/wl1271_rx.h
+++ b/drivers/net/wireless/wl12xx/wl1271_rx.h
@@ -113,7 +113,7 @@ struct wl1271_rx_descriptor {
 	u8  process_id;
 	u8  pad_len;
 	u8  reserved;
-} __attribute__ ((packed));
+} __packed;
 
 void wl1271_rx(struct wl1271 *wl, struct wl1271_fw_status *status);
 u8 wl1271_rate_to_idx(struct wl1271 *wl, int rate);
diff --git a/drivers/net/wireless/wl12xx/wl1271_tx.h b/drivers/net/wireless/wl12xx/wl1271_tx.h
index 3b8b7ac..91d0adb 100644
--- a/drivers/net/wireless/wl12xx/wl1271_tx.h
+++ b/drivers/net/wireless/wl12xx/wl1271_tx.h
@@ -80,7 +80,7 @@ struct wl1271_tx_hw_descr {
 	/* Identifier of the remote STA in IBSS, 1 in infra-BSS */
 	u8 aid;
 	u8 reserved;
-} __attribute__ ((packed));
+} __packed;
 
 enum wl1271_tx_hw_res_status {
 	TX_SUCCESS          = 0,
@@ -115,13 +115,13 @@ struct wl1271_tx_hw_res_descr {
 	u8 rate_class_index;
 	/* for 4-byte alignment. */
 	u8 spare;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl1271_tx_hw_res_if {
 	__le32 tx_result_fw_counter;
 	__le32 tx_result_host_counter;
 	struct wl1271_tx_hw_res_descr tx_results_queue[TX_HW_RESULT_QUEUE_LEN];
-} __attribute__ ((packed));
+} __packed;
 
 static inline int wl1271_tx_get_queue(int queue)
 {
diff --git a/drivers/net/wireless/wl12xx/wl12xx_80211.h b/drivers/net/wireless/wl12xx/wl12xx_80211.h
index 055d7bc..1846280 100644
--- a/drivers/net/wireless/wl12xx/wl12xx_80211.h
+++ b/drivers/net/wireless/wl12xx/wl12xx_80211.h
@@ -66,41 +66,41 @@ struct ieee80211_header {
 	u8 bssid[ETH_ALEN];
 	__le16 seq_ctl;
 	u8 payload[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl12xx_ie_header {
 	u8 id;
 	u8 len;
-} __attribute__ ((packed));
+} __packed;
 
 /* IEs */
 
 struct wl12xx_ie_ssid {
 	struct wl12xx_ie_header header;
 	char ssid[IW_ESSID_MAX_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl12xx_ie_rates {
 	struct wl12xx_ie_header header;
 	u8 rates[MAX_SUPPORTED_RATES];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl12xx_ie_ds_params {
 	struct wl12xx_ie_header header;
 	u8 channel;
-} __attribute__ ((packed));
+} __packed;
 
 struct country_triplet {
 	u8 channel;
 	u8 num_channels;
 	u8 max_tx_power;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl12xx_ie_country {
 	struct wl12xx_ie_header header;
 	u8 country_string[COUNTRY_STRING_LEN];
 	struct country_triplet triplets[MAX_COUNTRY_TRIPLETS];
-} __attribute__ ((packed));
+} __packed;
 
 
 /* Templates */
@@ -115,30 +115,30 @@ struct wl12xx_beacon_template {
 	struct wl12xx_ie_rates ext_rates;
 	struct wl12xx_ie_ds_params ds_params;
 	struct wl12xx_ie_country country;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl12xx_null_data_template {
 	struct ieee80211_header header;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl12xx_ps_poll_template {
 	__le16 fc;
 	__le16 aid;
 	u8 bssid[ETH_ALEN];
 	u8 ta[ETH_ALEN];
-} __attribute__ ((packed));
+} __packed;
 
 struct wl12xx_qos_null_data_template {
 	struct ieee80211_header header;
 	__le16 qos_ctl;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl12xx_probe_req_template {
 	struct ieee80211_header header;
 	struct wl12xx_ie_ssid ssid;
 	struct wl12xx_ie_rates rates;
 	struct wl12xx_ie_rates ext_rates;
-} __attribute__ ((packed));
+} __packed;
 
 
 struct wl12xx_probe_resp_template {
@@ -151,6 +151,6 @@ struct wl12xx_probe_resp_template {
 	struct wl12xx_ie_rates ext_rates;
 	struct wl12xx_ie_ds_params ds_params;
 	struct wl12xx_ie_country country;
-} __attribute__ ((packed));
+} __packed;
 
 #endif
diff --git a/drivers/net/wireless/wl3501.h b/drivers/net/wireless/wl3501.h
index 8816e37..3fbfd19 100644
--- a/drivers/net/wireless/wl3501.h
+++ b/drivers/net/wireless/wl3501.h
@@ -231,12 +231,12 @@ struct iw_mgmt_info_element {
 		  but sizeof(enum) > sizeof(u8) :-( */
 	u8 len;
 	u8 data[0];
-} __attribute__ ((packed));
+} __packed;
 
 struct iw_mgmt_essid_pset {
 	struct iw_mgmt_info_element el;
 	u8 			    essid[IW_ESSID_MAX_SIZE];
-} __attribute__ ((packed));
+} __packed;
 
 /*
  * According to 802.11 Wireless Netowors, the definitive guide - O'Reilly
@@ -247,12 +247,12 @@ struct iw_mgmt_essid_pset {
 struct iw_mgmt_data_rset {
 	struct iw_mgmt_info_element el;
 	u8 			    data_rate_labels[IW_DATA_RATE_MAX_LABELS];
-} __attribute__ ((packed));
+} __packed;
 
 struct iw_mgmt_ds_pset {
 	struct iw_mgmt_info_element el;
 	u8 			    chan;
-} __attribute__ ((packed));
+} __packed;
 
 struct iw_mgmt_cf_pset {
 	struct iw_mgmt_info_element el;
@@ -260,12 +260,12 @@ struct iw_mgmt_cf_pset {
 	u8 			    cfp_period;
 	u16 			    cfp_max_duration;
 	u16 			    cfp_dur_remaining;
-} __attribute__ ((packed));
+} __packed;
 
 struct iw_mgmt_ibss_pset {
 	struct iw_mgmt_info_element el;
 	u16 			    atim_window;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl3501_tx_hdr {
 	u16	tx_cnt;
@@ -544,12 +544,12 @@ struct wl3501_80211_tx_plcp_hdr {
 	u8	service;
 	u16	len;
 	u16	crc16;
-} __attribute__ ((packed));
+} __packed;
 
 struct wl3501_80211_tx_hdr {
 	struct wl3501_80211_tx_plcp_hdr	pclp_hdr;
 	struct ieee80211_hdr		mac_hdr;
-} __attribute__ ((packed));
+} __packed;
 
 /*
    Reserve the beginning Tx space for descriptor use.
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index 630c298..e4c70e3 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -35,7 +35,7 @@ struct zd_ctrlset {
 	__le16 current_length;
 	u8     service;
 	__le16  next_frame_length;
-} __attribute__((packed));
+} __packed;
 
 #define ZD_CS_RESERVED_SIZE	25
 
@@ -106,7 +106,7 @@ struct zd_ctrlset {
 struct rx_length_info {
 	__le16 length[3];
 	__le16 tag;
-} __attribute__((packed));
+} __packed;
 
 #define RX_LENGTH_INFO_TAG		0x697e
 
@@ -117,7 +117,7 @@ struct rx_status {
 	u8 signal_quality_ofdm;
 	u8 decryption_type;
 	u8 frame_status;
-} __attribute__((packed));
+} __packed;
 
 /* rx_status field decryption_type */
 #define ZD_RX_NO_WEP	0
@@ -153,7 +153,7 @@ struct tx_status {
 	u8 mac[ETH_ALEN];
 	u8 retry;
 	u8 failure;
-} __attribute__((packed));
+} __packed;
 
 enum mac_flags {
 	MAC_FIXED_CHANNEL = 0x01,
@@ -225,7 +225,7 @@ enum {
 struct ofdm_plcp_header {
 	u8 prefix[3];
 	__le16 service;
-} __attribute__((packed));
+} __packed;
 
 static inline u8 zd_ofdm_plcp_header_rate(const struct ofdm_plcp_header *header)
 {
@@ -252,7 +252,7 @@ struct cck_plcp_header {
 	u8 service;
 	__le16 length;
 	__le16 crc16;
-} __attribute__((packed));
+} __packed;
 
 static inline u8 zd_cck_plcp_header_signal(const struct cck_plcp_header *header)
 {
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index 049f8b9..1b1655c 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -79,17 +79,17 @@ enum control_requests {
 struct usb_req_read_regs {
 	__le16 id;
 	__le16 addr[0];
-} __attribute__((packed));
+} __packed;
 
 struct reg_data {
 	__le16 addr;
 	__le16 value;
-} __attribute__((packed));
+} __packed;
 
 struct usb_req_write_regs {
 	__le16 id;
 	struct reg_data reg_writes[0];
-} __attribute__((packed));
+} __packed;
 
 enum {
 	RF_IF_LE = 0x02,
@@ -106,7 +106,7 @@ struct usb_req_rfwrite {
 	/* RF2595: 24 */
 	__le16 bit_values[0];
 	/* (CR203 & ~(RF_IF_LE | RF_CLK | RF_DATA)) | (bit ? RF_DATA : 0) */
-} __attribute__((packed));
+} __packed;
 
 /* USB interrupt */
 
@@ -123,12 +123,12 @@ enum usb_int_flags {
 struct usb_int_header {
 	u8 type;	/* must always be 1 */
 	u8 id;
-} __attribute__((packed));
+} __packed;
 
 struct usb_int_regs {
 	struct usb_int_header hdr;
 	struct reg_data regs[0];
-} __attribute__((packed));
+} __packed;
 
 struct usb_int_retry_fail {
 	struct usb_int_header hdr;
@@ -136,7 +136,7 @@ struct usb_int_retry_fail {
 	u8 _dummy;
 	u8 addr[ETH_ALEN];
 	u8 ibss_wakeup_dest;
-} __attribute__((packed));
+} __packed;
 
 struct read_regs_int {
 	struct completion completion;



From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 6/8] orinoco: Annotate endianess of variables and structure members.
Date: Fri, 23 Sep 2005 04:18:06 -0400
Message-ID: <E1EIikw-0003k9-9e@gnu.org>
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Annotate endianess of variables and structure members.

Don't reuse variables for both host-endian and little-endian data.
Minor comment changes in affected structures.

diff --git a/drivers/net/wireless/hermes.h b/drivers/net/wireless/hermes.h
--- a/drivers/net/wireless/hermes.h
+++ b/drivers/net/wireless/hermes.h
@@ -191,13 +191,13 @@
 #define	HERMES_RXSTAT_WMP		(0x6000)	/* Wavelan-II Management Protocol frame */
 
 struct hermes_tx_descriptor {
-	u16 status;
-	u16 reserved1;
-	u16 reserved2;
-	u32 sw_support;
+	__le16 status;
+	__le16 reserved1;
+	__le16 reserved2;
+	__le32 sw_support;
 	u8 retry_count;
 	u8 tx_rate;
-	u16 tx_control;	
+	__le16 tx_control;	
 } __attribute__ ((packed));
 
 #define HERMES_TXSTAT_RETRYERR		(0x0001)
@@ -221,60 +221,60 @@ struct hermes_tx_descriptor {
 #define HERMES_INQ_SEC_STAT_AGERE	(0xF202)
 
 struct hermes_tallies_frame {
-	u16 TxUnicastFrames;
-	u16 TxMulticastFrames;
-	u16 TxFragments;
-	u16 TxUnicastOctets;
-	u16 TxMulticastOctets;
-	u16 TxDeferredTransmissions;
-	u16 TxSingleRetryFrames;
-	u16 TxMultipleRetryFrames;
-	u16 TxRetryLimitExceeded;
-	u16 TxDiscards;
-	u16 RxUnicastFrames;
-	u16 RxMulticastFrames;
-	u16 RxFragments;
-	u16 RxUnicastOctets;
-	u16 RxMulticastOctets;
-	u16 RxFCSErrors;
-	u16 RxDiscards_NoBuffer;
-	u16 TxDiscardsWrongSA;
-	u16 RxWEPUndecryptable;
-	u16 RxMsgInMsgFragments;
-	u16 RxMsgInBadMsgFragments;
+	__le16 TxUnicastFrames;
+	__le16 TxMulticastFrames;
+	__le16 TxFragments;
+	__le16 TxUnicastOctets;
+	__le16 TxMulticastOctets;
+	__le16 TxDeferredTransmissions;
+	__le16 TxSingleRetryFrames;
+	__le16 TxMultipleRetryFrames;
+	__le16 TxRetryLimitExceeded;
+	__le16 TxDiscards;
+	__le16 RxUnicastFrames;
+	__le16 RxMulticastFrames;
+	__le16 RxFragments;
+	__le16 RxUnicastOctets;
+	__le16 RxMulticastOctets;
+	__le16 RxFCSErrors;
+	__le16 RxDiscards_NoBuffer;
+	__le16 TxDiscardsWrongSA;
+	__le16 RxWEPUndecryptable;
+	__le16 RxMsgInMsgFragments;
+	__le16 RxMsgInBadMsgFragments;
 	/* Those last are probably not available in very old firmwares */
-	u16 RxDiscards_WEPICVError;
-	u16 RxDiscards_WEPExcluded;
+	__le16 RxDiscards_WEPICVError;
+	__le16 RxDiscards_WEPExcluded;
 } __attribute__ ((packed));
 
 /* Grabbed from wlan-ng - Thanks Mark... - Jean II
  * This is the result of a scan inquiry command */
 /* Structure describing info about an Access Point */
 struct prism2_scan_apinfo {
-	u16 channel;		/* Channel where the AP sits */
-	u16 noise;		/* Noise level */
-	u16 level;		/* Signal level */
+	__le16 channel;		/* Channel where the AP sits */
+	__le16 noise;		/* Noise level */
+	__le16 level;		/* Signal level */
 	u8 bssid[ETH_ALEN];	/* MAC address of the Access Point */
-	u16 beacon_interv;	/* Beacon interval */
-	u16 capabilities;	/* Capabilities */
-	u16 essid_len;		/* ESSID length */
+	__le16 beacon_interv;	/* Beacon interval */
+	__le16 capabilities;	/* Capabilities */
+	__le16 essid_len;	/* ESSID length */
 	u8 essid[32];		/* ESSID of the network */
 	u8 rates[10];		/* Bit rate supported */
-	u16 proberesp_rate;	/* Data rate of the response frame */
-	u16 atim;		/* ATIM window time, Kus (hostscan only) */
+	__le16 proberesp_rate;	/* Data rate of the response frame */
+	__le16 atim;		/* ATIM window time, Kus (hostscan only) */
 } __attribute__ ((packed));
 
 /* Same stuff for the Lucent/Agere card.
  * Thanks to h1kari <h1kari AT dachb0den.com> - Jean II */
 struct agere_scan_apinfo {
-	u16 channel;		/* Channel where the AP sits */
-	u16 noise;		/* Noise level */
-	u16 level;		/* Signal level */
+	__le16 channel;		/* Channel where the AP sits */
+	__le16 noise;		/* Noise level */
+	__le16 level;		/* Signal level */
 	u8 bssid[ETH_ALEN];	/* MAC address of the Access Point */
-	u16 beacon_interv;	/* Beacon interval */
-	u16 capabilities;	/* Capabilities */
+	__le16 beacon_interv;	/* Beacon interval */
+	__le16 capabilities;	/* Capabilities */
 	/* bits: 0-ess, 1-ibss, 4-privacy [wep] */
-	u16 essid_len;		/* ESSID length */
+	__le16 essid_len;	/* ESSID length */
 	u8 essid[32];		/* ESSID of the network */
 } __attribute__ ((packed));
 
@@ -282,16 +282,16 @@ struct agere_scan_apinfo {
 struct symbol_scan_apinfo {
 	u8 channel;		/* Channel where the AP sits */
 	u8 unknown1;		/* 8 in 2.9x and 3.9x f/w, 0 otherwise */
-	u16 noise;		/* Noise level */
-	u16 level;		/* Signal level */
+	__le16 noise;		/* Noise level */
+	__le16 level;		/* Signal level */
 	u8 bssid[ETH_ALEN];	/* MAC address of the Access Point */
-	u16 beacon_interv;	/* Beacon interval */
-	u16 capabilities;	/* Capabilities */
+	__le16 beacon_interv;	/* Beacon interval */
+	__le16 capabilities;	/* Capabilities */
 	/* bits: 0-ess, 1-ibss, 4-privacy [wep] */
-	u16 essid_len;		/* ESSID length */
+	__le16 essid_len;	/* ESSID length */
 	u8 essid[32];		/* ESSID of the network */
-    	u16 rates[5];		/* Bit rate supported */
-	u16 basic_rates;	/* Basic rates bitmask */
+    	__le16 rates[5];	/* Bit rate supported */
+	__le16 basic_rates;	/* Basic rates bitmask */
 	u8 unknown2[6];		/* Always FF:FF:FF:FF:00:00 */
 	u8 unknown3[8];		/* Always 0, appeared in f/w 3.91-68 */
 } __attribute__ ((packed));
@@ -311,7 +311,7 @@ union hermes_scan_info {
 #define HERMES_LINKSTATUS_ASSOC_FAILED    (0x0006)
   
 struct hermes_linkstatus {
-	u16 linkstatus;         /* Link status */
+	__le16 linkstatus;         /* Link status */
 } __attribute__ ((packed));
 
 struct hermes_response {
@@ -320,8 +320,8 @@ struct hermes_response {
 
 /* "ID" structure - used for ESSID and station nickname */
 struct hermes_idstring {
-	u16 len;
-	u16 val[16];
+	__le16 len;
+	__le16 val[16];
 } __attribute__ ((packed));
 
 struct hermes_multicast {
@@ -446,7 +446,7 @@ static inline void hermes_clear_words(st
 
 static inline int hermes_read_wordrec(hermes_t *hw, int bap, u16 rid, u16 *word)
 {
-	u16 rec;
+	__le16 rec;
 	int err;
 
 	err = HERMES_READ_RECORD(hw, bap, rid, &rec);
@@ -456,7 +456,7 @@ static inline int hermes_read_wordrec(he
 
 static inline int hermes_write_wordrec(hermes_t *hw, int bap, u16 rid, u16 word)
 {
-	u16 rec = cpu_to_le16(word);
+	__le16 rec = cpu_to_le16(word);
 	return HERMES_WRITE_RECORD(hw, bap, rid, &rec);
 }
 
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -202,31 +202,32 @@ static struct {
 /********************************************************************/
 
 /* Used in Event handling.
- * We avoid nested structres as they break on ARM -- Moustafa */
+ * We avoid nested structures as they break on ARM -- Moustafa */
 struct hermes_tx_descriptor_802_11 {
 	/* hermes_tx_descriptor */
-	u16 status;
-	u16 reserved1;
-	u16 reserved2;
-	u32 sw_support;
+	__le16 status;
+	__le16 reserved1;
+	__le16 reserved2;
+	__le32 sw_support;
 	u8 retry_count;
 	u8 tx_rate;
-	u16 tx_control;
+	__le16 tx_control;
 
-	/* ieee802_11_hdr */
-	u16 frame_ctl;
-	u16 duration_id;
+	/* ieee80211_hdr */
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
-	u16 seq_ctl;
+	__le16 seq_ctl;
 	u8 addr4[ETH_ALEN];
-	u16 data_len;
+
+	__le16 data_len;
 
 	/* ethhdr */
-	unsigned char   h_dest[ETH_ALEN];       /* destination eth addr */
-	unsigned char   h_source[ETH_ALEN];     /* source ether addr    */
-	unsigned short  h_proto;                /* packet type ID field */
+	u8 h_dest[ETH_ALEN];	/* destination eth addr */
+	u8 h_source[ETH_ALEN];	/* source ether addr    */
+	__be16 h_proto;		/* packet type ID field */
 
 	/* p8022_hdr */
 	u8 dsap;
@@ -234,31 +235,31 @@ struct hermes_tx_descriptor_802_11 {
 	u8 ctrl;
 	u8 oui[3];
 
-	u16 ethertype;
+	__be16 ethertype;
 } __attribute__ ((packed));
 
 /* Rx frame header except compatibility 802.3 header */
 struct hermes_rx_descriptor {
 	/* Control */
-	u16 status;
-	u32 time;
+	__le16 status;
+	__le32 time;
 	u8 silence;
 	u8 signal;
 	u8 rate;
 	u8 rxflow;
-	u32 reserved;
+	__le32 reserved;
 
 	/* 802.11 header */
-	u16 frame_ctl;
-	u16 duration_id;
+	__le16 frame_ctl;
+	__le16 duration_id;
 	u8 addr1[ETH_ALEN];
 	u8 addr2[ETH_ALEN];
 	u8 addr3[ETH_ALEN];
-	u16 seq_ctl;
+	__le16 seq_ctl;
 	u8 addr4[ETH_ALEN];
 
 	/* Data length */
-	u16 data_len;
+	__le16 data_len;
 } __attribute__ ((packed));
 
 /********************************************************************/
@@ -389,7 +390,7 @@ static struct iw_statistics *orinoco_get
 		}
 	} else {
 		struct {
-			u16 qual, signal, noise;
+			__le16 qual, signal, noise;
 		} __attribute__ ((packed)) cq;
 
 		err = HERMES_READ_RECORD(hw, USER_BAP,
@@ -615,6 +616,7 @@ static void __orinoco_ev_txexc(struct ne
 	struct orinoco_private *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &priv->stats;
 	u16 fid = hermes_read_regn(hw, TXCOMPLFID);
+	u16 status;
 	struct hermes_tx_descriptor_802_11 hdr;
 	int err = 0;
 
@@ -644,8 +646,8 @@ static void __orinoco_ev_txexc(struct ne
 	 * exceeded, because that's the only status that really mean
 	 * that this particular node went away.
 	 * Other errors means that *we* screwed up. - Jean II */
-	hdr.status = le16_to_cpu(hdr.status);
-	if (hdr.status & (HERMES_TXSTAT_RETRYERR | HERMES_TXSTAT_AGEDERR)) {
+	status = le16_to_cpu(hdr.status);
+	if (status & (HERMES_TXSTAT_RETRYERR | HERMES_TXSTAT_AGEDERR)) {
 		union iwreq_data	wrqu;
 
 		/* Copy 802.11 dest address.
@@ -1031,7 +1033,7 @@ static void orinoco_join_ap(struct net_d
 	unsigned long flags;
 	struct join_req {
 		u8 bssid[ETH_ALEN];
-		u16 channel;
+		__le16 channel;
 	} __attribute__ ((packed)) req;
 	const int atom_len = offsetof(struct prism2_scan_apinfo, atim);
 	struct prism2_scan_apinfo *atom = NULL;
@@ -1128,8 +1130,8 @@ static void __orinoco_ev_info(struct net
 	struct orinoco_private *priv = netdev_priv(dev);
 	u16 infofid;
 	struct {
-		u16 len;
-		u16 type;
+		__le16 len;
+		__le16 type;
 	} __attribute__ ((packed)) info;
 	int len, type;
 	int err;
@@ -3905,7 +3907,7 @@ static int orinoco_ioctl_setscan(struct 
 						   HERMES_HOSTSCAN_SYMBOL_BCAST);
 			break;
 		case FIRMWARE_TYPE_INTERSIL: {
-			u16 req[3];
+			__le16 req[3];
 
 			req[0] = cpu_to_le16(0x3fff);	/* All channels */
 			req[1] = cpu_to_le16(0x0001);	/* rate 1 Mbps */
@@ -3979,7 +3981,7 @@ static inline int orinoco_translate_scan
 	case FIRMWARE_TYPE_INTERSIL:
 		offset = 4;
 		if (priv->has_hostscan) {
-			atom_len = le16_to_cpup((u16 *)scan);
+			atom_len = le16_to_cpup((__le16 *)scan);
 			/* Sanity check for atom_len */
 			if (atom_len < sizeof(struct prism2_scan_apinfo)) {
 				printk(KERN_ERR "%s: Invalid atom_len in scan data: %d\n",
diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -27,7 +27,7 @@
 #define ORINOCO_MAX_KEYS	4
 
 struct orinoco_key {
-	u16 len;	/* always stored as little-endian */
+	__le16 len;	/* always stored as little-endian */
 	char data[ORINOCO_MAX_KEY_SIZE];
 } __attribute__ ((packed));
 
@@ -35,14 +35,14 @@ struct header_struct {
 	/* 802.3 */
 	u8 dest[ETH_ALEN];
 	u8 src[ETH_ALEN];
-	u16 len;
+	__be16 len;
 	/* 802.2 */
 	u8 dsap;
 	u8 ssap;
 	u8 ctrl;
 	/* SNAP */
 	u8 oui[3];
-	u16 ethertype;
+	unsigned short ethertype;
 } __attribute__ ((packed));
 
 typedef enum {
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -138,8 +138,8 @@ static void spectrum_cs_detach(dev_link_
  * Each block has the following structure.
  */
 struct dblock {
-	u32 _addr;		/* adapter address where to write the block */
-	u16 _len;		/* length of the data only, in bytes */
+	__le32 _addr;		/* adapter address where to write the block */
+	__le16 _len;		/* length of the data only, in bytes */
 	char data[0];		/* data to be written */
 } __attribute__ ((packed));
 
@@ -149,9 +149,9 @@ struct dblock {
  * items with matching ID should be written.
  */
 struct pdr {
-	u32 _id;		/* record ID */
-	u32 _addr;		/* adapter address where to write the data */
-	u32 _len;		/* expected length of the data, in bytes */
+	__le32 _id;		/* record ID */
+	__le32 _addr;		/* adapter address where to write the data */
+	__le32 _len;		/* expected length of the data, in bytes */
 	char next[0];		/* next PDR starts here */
 } __attribute__ ((packed));
 
@@ -162,8 +162,8 @@ struct pdr {
  * be plugged into the secondary firmware.
  */
 struct pdi {
-	u16 _len;		/* length of ID and data, in words */
-	u16 _id;		/* record ID */
+	__le16 _len;		/* length of ID and data, in words */
+	__le16 _id;		/* record ID */
 	char data[0];		/* plug data */
 } __attribute__ ((packed));;
 
@@ -370,7 +370,7 @@ spectrum_plug_pdi(hermes_t *hw, struct p
 
 /* Read PDA from the adapter */
 static int
-spectrum_read_pda(hermes_t *hw, u16 *pda, int pda_len)
+spectrum_read_pda(hermes_t *hw, __le16 *pda, int pda_len)
 {
 	int ret;
 	int pda_size;
@@ -401,7 +401,7 @@ spectrum_read_pda(hermes_t *hw, u16 *pda
 /* Parse PDA and write the records into the adapter */
 static int
 spectrum_apply_pda(hermes_t *hw, const struct dblock *first_block,
-		   u16 *pda)
+		   __le16 *pda)
 {
 	int ret;
 	struct pdi *pdi;
@@ -467,7 +467,7 @@ spectrum_dl_image(hermes_t *hw, dev_link
 	const struct dblock *first_block;
 
 	/* Plug Data Area (PDA) */
-	u16 pda[PDA_WORDS];
+	__le16 pda[PDA_WORDS];
 
 	/* Binary block begins after the 0x1A marker */
 	ptr = image;



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php

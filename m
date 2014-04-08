From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 1/2] FDDI: Reformat <linux/if_fddi.h> for 8-character tabs
Date: Tue, 8 Apr 2014 13:19:28 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1404080022120.26128@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:49249 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533AbaDHMTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 08:19:30 -0400
Received: from localhost.localdomain ([127.0.0.1]:39858 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6822541AbaDHMT3DCGMx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 14:19:29 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of our FDDI support code has been apparently written with an 
assumption that tabs are 4-character wide.  In preparation to the next
change this update reformats <linux/if_fddi.h> so that it stays within 79 
columns and otherwise renders correctly with 8-character tabs.  No 
functional change.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
Dave,

 Please apply or otherwise let me know if you have issues with this 
change.

 Thanks,

  Maciej

linux-if_fddi-format.patch
Index: linux/include/uapi/linux/if_fddi.h
===================================================================
--- linux.orig/include/uapi/linux/if_fddi.h
+++ linux/include/uapi/linux/if_fddi.h
@@ -30,74 +30,76 @@
  *  Define max and min legal sizes.  The frame sizes do not include
  *  4 byte FCS/CRC (frame check sequence).
  */
-#define FDDI_K_ALEN			6		/* Octets in one FDDI address */
-#define FDDI_K_8022_HLEN	16		/* Total octets in 802.2 header */
-#define FDDI_K_SNAP_HLEN	21		/* Total octets in 802.2 SNAP header */
-#define FDDI_K_8022_ZLEN	16		/* Min octets in 802.2 frame sans FCS */
-#define FDDI_K_SNAP_ZLEN	21		/* Min octets in 802.2 SNAP frame sans FCS */
+#define FDDI_K_ALEN		6	/* Octets in one FDDI address */
+#define FDDI_K_8022_HLEN	16	/* Total octets in 802.2 header */
+#define FDDI_K_SNAP_HLEN	21	/* Total octets in 802.2 SNAP header */
+#define FDDI_K_8022_ZLEN	16	/* Min octets in 802.2 frame sans
+					   FCS */
+#define FDDI_K_SNAP_ZLEN	21	/* Min octets in 802.2 SNAP frame sans
+					   FCS */
 #define FDDI_K_8022_DLEN	4475	/* Max octets in 802.2 payload */
 #define FDDI_K_SNAP_DLEN	4470	/* Max octets in 802.2 SNAP payload */
-#define FDDI_K_LLC_ZLEN		13		/* Min octets in LLC frame sans FCS */
+#define FDDI_K_LLC_ZLEN		13	/* Min octets in LLC frame sans FCS */
 #define FDDI_K_LLC_LEN		4491	/* Max octets in LLC frame sans FCS */
+#define FDDI_K_OUI_LEN		3	/* Octets in OUI in 802.2 SNAP
+					   header */
 
 /* Define FDDI Frame Control (FC) Byte values */
-#define FDDI_FC_K_VOID					0x00	
-#define FDDI_FC_K_NON_RESTRICTED_TOKEN	0x80	
-#define FDDI_FC_K_RESTRICTED_TOKEN		0xC0	
-#define FDDI_FC_K_SMT_MIN				0x41
-#define FDDI_FC_K_SMT_MAX		   		0x4F
-#define FDDI_FC_K_MAC_MIN				0xC1
-#define FDDI_FC_K_MAC_MAX		  		0xCF	
-#define FDDI_FC_K_ASYNC_LLC_MIN			0x50
-#define FDDI_FC_K_ASYNC_LLC_DEF			0x54
-#define FDDI_FC_K_ASYNC_LLC_MAX			0x5F
-#define FDDI_FC_K_SYNC_LLC_MIN			0xD0
-#define FDDI_FC_K_SYNC_LLC_MAX			0xD7
-#define FDDI_FC_K_IMPLEMENTOR_MIN		0x60
-#define FDDI_FC_K_IMPLEMENTOR_MAX  		0x6F
-#define FDDI_FC_K_RESERVED_MIN			0x70
-#define FDDI_FC_K_RESERVED_MAX			0x7F
+#define FDDI_FC_K_VOID			0x00
+#define FDDI_FC_K_NON_RESTRICTED_TOKEN	0x80
+#define FDDI_FC_K_RESTRICTED_TOKEN	0xC0
+#define FDDI_FC_K_SMT_MIN		0x41
+#define FDDI_FC_K_SMT_MAX		0x4F
+#define FDDI_FC_K_MAC_MIN		0xC1
+#define FDDI_FC_K_MAC_MAX		0xCF
+#define FDDI_FC_K_ASYNC_LLC_MIN		0x50
+#define FDDI_FC_K_ASYNC_LLC_DEF		0x54
+#define FDDI_FC_K_ASYNC_LLC_MAX		0x5F
+#define FDDI_FC_K_SYNC_LLC_MIN		0xD0
+#define FDDI_FC_K_SYNC_LLC_MAX		0xD7
+#define FDDI_FC_K_IMPLEMENTOR_MIN	0x60
+#define FDDI_FC_K_IMPLEMENTOR_MAX	0x6F
+#define FDDI_FC_K_RESERVED_MIN		0x70
+#define FDDI_FC_K_RESERVED_MAX		0x7F
 
 /* Define LLC and SNAP constants */
-#define FDDI_EXTENDED_SAP	0xAA
+#define FDDI_EXTENDED_SAP		0xAA
 #define FDDI_UI_CMD			0x03
 
 /* Define 802.2 Type 1 header */
 struct fddi_8022_1_hdr {
-	__u8	dsap;					/* destination service access point */
-	__u8	ssap;					/* source service access point */
-	__u8	ctrl;					/* control byte #1 */
+	__u8	dsap;			/* destination service access point */
+	__u8	ssap;			/* source service access point */
+	__u8	ctrl;			/* control byte #1 */
 } __attribute__((packed));
 
 /* Define 802.2 Type 2 header */
 struct fddi_8022_2_hdr {
-	__u8	dsap;					/* destination service access point */
-	__u8	ssap;					/* source service access point */
-	__u8	ctrl_1;					/* control byte #1 */
-	__u8	ctrl_2;					/* control byte #2 */
+	__u8	dsap;			/* destination service access point */
+	__u8	ssap;			/* source service access point */
+	__u8	ctrl_1;			/* control byte #1 */
+	__u8	ctrl_2;			/* control byte #2 */
 } __attribute__((packed));
 
 /* Define 802.2 SNAP header */
-#define FDDI_K_OUI_LEN	3
 struct fddi_snap_hdr {
-	__u8	dsap;					/* always 0xAA */
-	__u8	ssap;					/* always 0xAA */
-	__u8	ctrl;					/* always 0x03 */
+	__u8	dsap;			/* always 0xAA */
+	__u8	ssap;			/* always 0xAA */
+	__u8	ctrl;			/* always 0x03 */
 	__u8	oui[FDDI_K_OUI_LEN];	/* organizational universal id */
-	__be16	ethertype;				/* packet type ID field */
+	__be16	ethertype;		/* packet type ID field */
 } __attribute__((packed));
 
 /* Define FDDI LLC frame header */
 struct fddihdr {
-	__u8	fc;						/* frame control */
-	__u8	daddr[FDDI_K_ALEN];		/* destination address */
-	__u8	saddr[FDDI_K_ALEN];		/* source address */
-	union
-		{
-		struct fddi_8022_1_hdr		llc_8022_1;
-		struct fddi_8022_2_hdr		llc_8022_2;
-		struct fddi_snap_hdr		llc_snap;
-		} hdr;
+	__u8	fc;			/* frame control */
+	__u8	daddr[FDDI_K_ALEN];	/* destination address */
+	__u8	saddr[FDDI_K_ALEN];	/* source address */
+	union {
+		struct fddi_8022_1_hdr	llc_8022_1;
+		struct fddi_8022_2_hdr	llc_8022_2;
+		struct fddi_snap_hdr	llc_snap;
+	} hdr;
 } __attribute__((packed));
 
 

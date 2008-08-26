From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 02/13] ixgbe: add little endian annotations for sparse
Date: Tue, 26 Aug 2008 04:26:59 -0700
Message-ID: <20080826112659.15787.63620.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37405 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754303AbYHZL1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:00 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099738rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:26:59 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_type.h |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c0282a2..781f137 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1007,15 +1007,15 @@ struct ixgbe_legacy_tx_desc {
 		__le32 data;
 		struct {
 			__le16 length;    /* Data buffer length */
-			u8 cso; /* Checksum offset */
-			u8 cmd; /* Descriptor control */
+			u8 cso;           /* Checksum offset */
+			u8 cmd;           /* Descriptor control */
 		} flags;
 	} lower;
 	union {
 		__le32 data;
 		struct {
 			u8 status;     /* Descriptor status */
-			u8 css; /* Checksum start */
+			u8 css;        /* Checksum start */
 			__le16 vlan;
 		} fields;
 	} upper;
@@ -1039,9 +1039,9 @@ union ixgbe_adv_tx_desc {
 struct ixgbe_legacy_rx_desc {
 	__le64 buffer_addr; /* Address of the descriptor's data buffer */
 	__le16 length;      /* Length of data DMAed into data buffer */
-	u16 csum;        /* Packet checksum */
-	u8 status;       /* Descriptor status */
-	u8 errors;       /* Descriptor Errors */
+	__le16 csum;        /* Packet checksum */
+	u8 status;          /* Descriptor status */
+	u8 errors;          /* Descriptor Errors */
 	__le16 vlan;
 };
 
@@ -1061,7 +1061,7 @@ union ixgbe_adv_rx_desc {
 				__le32 rss; /* RSS Hash */
 				struct {
 					__le16 ip_id; /* IP id */
-					u16 csum; /* Packet Checksum */
+					__le16 csum; /* Packet Checksum */
 				} csum_ip;
 			} hi_dword;
 		} lower;


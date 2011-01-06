From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Thu, 6 Jan 2011 16:05:26 +0100
Message-ID: <20110106150525.GB324@e-circ.dyndns.org>
References: <20110104150513.GA321@e-circ.dyndns.org>
 <20110104150759.GB321@e-circ.dyndns.org>
 <4D24DB2C.9040104@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:33218 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753036Ab1AFPFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 10:05:38 -0500
Content-Disposition: inline
In-Reply-To: <4D24DB2C.9040104@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wolfgang,

On Wed, Jan 05, 2011 at 09:57:16PM +0100, Wolfgang Grandegger wrote:
> 
> here comes my review... First some general remarks. As Mark already
> pointed out, there are still some coding style issues:
Oops, I tried to eliminate those.
> 
> - Please use the following style for multi line comments:
shame on me. I should have done them all after Mark pointed me to it.
> 
> - Please avoid alignment of expressions and structure members.
I see:
diff --git a/include/linux/can.h b/include/linux/can.h
index d183333..6b1e5a6 100644
--- a/include/linux/can.h
+++ b/include/linux/can.h
@@ -56,18 +56,18 @@ typedef __u32 can_err_mask_t;
  */
 struct can_frame {
 	canid_t can_id;  /* 32 bit CAN_ID + EFF/RTR/ERR flags */
-	__u8    can_dlc; /* data length code: 0 .. 8 */
-	__u8    data[8] __attribute__((aligned(8)));
+	__u8 can_dlc; /* data length code: 0 .. 8 */
+	__u8 data[8] __attribute__((aligned(8)));
 };
 
 /* particular protocols of the protocol family PF_CAN */
-#define CAN_RAW		1 /* RAW sockets */
-#define CAN_BCM		2 /* Broadcast Manager */
-#define CAN_TP16	3 /* VAG Transport Protocol v1.6 */
-#define CAN_TP20	4 /* VAG Transport Protocol v2.0 */
-#define CAN_MCNET	5 /* Bosch MCNet */
-#define CAN_ISOTP	6 /* ISO 15765-2 Transport Protocol */
-#define CAN_NPROTO	7
+#define CAN_RAW 1 /* RAW sockets */
+#define CAN_BCM 2 /* Broadcast Manager */
+#define CAN_TP16 3 /* VAG Transport Protocol v1.6 */
+#define CAN_TP20 4 /* VAG Transport Protocol v2.0 */
+#define CAN_MCNET 5 /* Bosch MCNet */
+#define CAN_ISOTP 6 /* ISO 15765-2 Transport Protocol */
+#define CAN_NPROTO 7
 
 #define SOL_CAN_BASE 100
 
@@ -79,7 +79,7 @@ struct can_frame {
  */
 struct sockaddr_can {
 	sa_family_t can_family;
-	int         can_ifindex;
+	int can_ifindex;
 	union {
 		/* transport protocol class address information (e.g. ISOTP) */
 		struct { canid_t rx_id, tx_id; } tp;

I applied a search pattern on this, since I seem incapable of finding
alignment problems in my own code :-).
I assume alignment is ok for definitions, but not within functions?
I consulted the Documentation/Coding-style, but I did not find
the exact answer.
> 
> More comments inline...
More to process for me too ...

Kurt

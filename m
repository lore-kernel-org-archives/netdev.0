From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH 3/8] : replace `__attribute' by `__attribute__'
Date: Tue, 01 Apr 2008 19:36:55 +0200
Message-ID: <47F272B7.6020701@tiscali.nl>
References: <47F26FF6.8070300@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, lkml <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:32870 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756362AbYDARg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 13:36:59 -0400
In-Reply-To: <47F26FF6.8070300@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace `__attribute' by `__attribute__'

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/3c527.h b/drivers/net/3c527.h
index 75e28fe..21c59bd 100644
--- a/drivers/net/3c527.h
+++ b/drivers/net/3c527.h
@@ -34,7 +34,7 @@ struct mc32_mailbox
 {
  	u16 mbox;
  	u16 data[1];
-} __attribute((packed));
+} __attribute__((packed));
 
 struct skb_header
 {
@@ -43,7 +43,7 @@ struct skb_header
 	u16 next;	/* Do not change! */
 	u16 length;
 	u32 data;
-} __attribute((packed));
+} __attribute__((packed));
 
 struct mc32_stats
 {
@@ -68,7 +68,7 @@ struct mc32_stats
 	u32 dataA[6];
 	u16 dataB[5];
 	u32 dataC[14];
-} __attribute((packed));
+} __attribute__((packed));
 
 #define STATUS_MASK	0x0F
 #define COMPLETED	(1<<7)
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/net/irda/vlsi_ir.h
index c8b9c74..200af2b 100644
--- a/drivers/net/irda/vlsi_ir.h
+++ b/drivers/net/irda/vlsi_ir.h
@@ -545,7 +545,7 @@ struct ring_descr_hw {
 			u8		addr_res[3];
 			volatile u8	status;		/* descriptor status */
 		} __attribute__((packed)) rd_s;
-	} __attribute((packed)) rd_u;
+	} __attribute__((packed)) rd_u;
 } __attribute__ ((packed));
 
 #define rd_addr		rd_u.addr
diff --git a/drivers/net/lib8390.c b/drivers/net/lib8390.c
index 0c5447d..c681056 100644
--- a/drivers/net/lib8390.c
+++ b/drivers/net/lib8390.c
@@ -1116,7 +1116,7 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 								int start_page)
 {
 	unsigned long e8390_base = dev->base_addr;
- 	struct ei_device *ei_local __attribute((unused)) = (struct ei_device *) netdev_priv(dev);
+ 	struct ei_device *ei_local __attribute__((unused)) = (struct ei_device *) netdev_priv(dev);
 
 	ei_outb_p(E8390_NODMA+E8390_PAGE0, e8390_base+E8390_CMD);
 
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index ce95c5d..69b31d4 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -1812,7 +1812,7 @@ static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 								int start_page)
 {
 	long e8390_base = dev->base_addr;
- 	struct ei_device *ei_local __attribute((unused)) = (struct ei_device *) netdev_priv(dev);
+ 	struct ei_device *ei_local __attribute__((unused)) = (struct ei_device *) netdev_priv(dev);
     
 	if (inb_p(e8390_base) & E8390_TRANS) 
 	{
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 7bb3ba9..8cae15f 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1947,21 +1947,21 @@ struct sky2_tx_le {
 	__le16	length;	/* also vlan tag or checksum start */
 	u8	ctrl;
 	u8	opcode;
-} __attribute((packed));
+} __attribute__((packed));
 
 struct sky2_rx_le {
 	__le32	addr;
 	__le16	length;
 	u8	ctrl;
 	u8	opcode;
-} __attribute((packed));
+} __attribute__((packed));
 
 struct sky2_status_le {
 	__le32	status;	/* also checksum */
 	__le16	length;	/* also vlan tag */
 	u8	css;
 	u8	opcode;
-} __attribute((packed));
+} __attribute__((packed));
 
 struct tx_ring_info {
 	struct sk_buff	*skb;



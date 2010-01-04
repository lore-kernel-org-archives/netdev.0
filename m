From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/5] drivers/net/mac8390.c: Indent case labels
Date: Mon,  4 Jan 2010 13:52:59 -0800
Message-ID: <eeef695a7575344f4b53d0f57975606602e08b18.1262630406.git.joe@perches.com>
References: <cover.1262630406.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1488 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914Ab0ADVxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2010 16:53:08 -0500
In-Reply-To: <cover.1262630406.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/mac8390.c |  252 ++++++++++++++++++++++++------------------------
 1 files changed, 126 insertions(+), 126 deletions(-)

diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index f8fa0c3..6b6f375 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -164,70 +164,70 @@ static void word_memcpy_fromcard(void *tp, const void *fp, int count);
 static enum mac8390_type __init mac8390_ident(struct nubus_dev *dev)
 {
 	switch (dev->dr_sw) {
-		case NUBUS_DRSW_3COM:
-			switch (dev->dr_hw) {
-				case NUBUS_DRHW_APPLE_SONIC_NB:
-				case NUBUS_DRHW_APPLE_SONIC_LC:
-				case NUBUS_DRHW_SONNET:
-					return MAC8390_NONE;
-					break;
-				default:
-					return MAC8390_APPLE;
-					break;
-			}
+	case NUBUS_DRSW_3COM:
+		switch (dev->dr_hw) {
+		case NUBUS_DRHW_APPLE_SONIC_NB:
+		case NUBUS_DRHW_APPLE_SONIC_LC:
+		case NUBUS_DRHW_SONNET:
+			return MAC8390_NONE;
 			break;
-
-		case NUBUS_DRSW_APPLE:
-			switch (dev->dr_hw) {
-				case NUBUS_DRHW_ASANTE_LC:
-					return MAC8390_NONE;
-					break;
-				case NUBUS_DRHW_CABLETRON:
-					return MAC8390_CABLETRON;
-					break;
-				default:
-					return MAC8390_APPLE;
-					break;
-			}
+		default:
+			return MAC8390_APPLE;
 			break;
+		}
+		break;
 
-		case NUBUS_DRSW_ASANTE:
-			return MAC8390_ASANTE;
+	case NUBUS_DRSW_APPLE:
+		switch (dev->dr_hw) {
+		case NUBUS_DRHW_ASANTE_LC:
+			return MAC8390_NONE;
 			break;
-
-		case NUBUS_DRSW_TECHWORKS:
-		case NUBUS_DRSW_DAYNA2:
-		case NUBUS_DRSW_DAYNA_LC:
-			if (dev->dr_hw == NUBUS_DRHW_CABLETRON)
-				return MAC8390_CABLETRON;
-			else
-				return MAC8390_APPLE;
+		case NUBUS_DRHW_CABLETRON:
+			return MAC8390_CABLETRON;
 			break;
-
-		case NUBUS_DRSW_FARALLON:
-			return MAC8390_FARALLON;
+		default:
+			return MAC8390_APPLE;
 			break;
+		}
+		break;
 
-		case NUBUS_DRSW_KINETICS:
-			switch (dev->dr_hw) {
-				case NUBUS_DRHW_INTERLAN:
-					return MAC8390_INTERLAN;
-					break;
-				default:
-					return MAC8390_KINETICS;
-					break;
-			}
-			break;
+	case NUBUS_DRSW_ASANTE:
+		return MAC8390_ASANTE;
+		break;
+
+	case NUBUS_DRSW_TECHWORKS:
+	case NUBUS_DRSW_DAYNA2:
+	case NUBUS_DRSW_DAYNA_LC:
+		if (dev->dr_hw == NUBUS_DRHW_CABLETRON)
+			return MAC8390_CABLETRON;
+		else
+			return MAC8390_APPLE;
+		break;
+
+	case NUBUS_DRSW_FARALLON:
+		return MAC8390_FARALLON;
+		break;
 
-		case NUBUS_DRSW_DAYNA:
-			// These correspond to Dayna Sonic cards
-			// which use the macsonic driver
-			if (dev->dr_hw == NUBUS_DRHW_SMC9194 ||
-				dev->dr_hw == NUBUS_DRHW_INTERLAN )
-				return MAC8390_NONE;
-			else
-				return MAC8390_DAYNA;
+	case NUBUS_DRSW_KINETICS:
+		switch (dev->dr_hw) {
+		case NUBUS_DRHW_INTERLAN:
+			return MAC8390_INTERLAN;
 			break;
+		default:
+			return MAC8390_KINETICS;
+			break;
+		}
+		break;
+
+	case NUBUS_DRSW_DAYNA:
+		// These correspond to Dayna Sonic cards
+		// which use the macsonic driver
+		if (dev->dr_hw == NUBUS_DRHW_SMC9194 ||
+		    dev->dr_hw == NUBUS_DRHW_INTERLAN )
+			return MAC8390_NONE;
+		else
+			return MAC8390_DAYNA;
+		break;
 	}
 	return MAC8390_NONE;
 }
@@ -373,54 +373,54 @@ struct net_device * __init mac8390_probe(int unit)
 			dev->mem_end = dev->mem_start + offset;
 		} else {
 			switch (cardtype) {
-				case MAC8390_KINETICS:
-				case MAC8390_DAYNA: /* it's the same */
-					dev->base_addr =
-						(int)(ndev->board->slot_addr +
-						DAYNA_8390_BASE);
-					dev->mem_start =
-						(int)(ndev->board->slot_addr +
-						DAYNA_8390_MEM);
-					dev->mem_end =
-						dev->mem_start +
-						mac8390_memsize(dev->mem_start);
-					break;
-				case MAC8390_INTERLAN:
-					dev->base_addr =
-						(int)(ndev->board->slot_addr +
-						INTERLAN_8390_BASE);
-					dev->mem_start =
-						(int)(ndev->board->slot_addr +
-						INTERLAN_8390_MEM);
-					dev->mem_end =
-						dev->mem_start +
-						mac8390_memsize(dev->mem_start);
-					break;
-				case MAC8390_CABLETRON:
-					dev->base_addr =
-						(int)(ndev->board->slot_addr +
-						CABLETRON_8390_BASE);
-					dev->mem_start =
-						(int)(ndev->board->slot_addr +
-						CABLETRON_8390_MEM);
-					/* The base address is unreadable if 0x00
-					 * has been written to the command register
-					 * Reset the chip by writing E8390_NODMA +
-					 *   E8390_PAGE0 + E8390_STOP just to be
-					 *   sure
-					 */
-					i = (void *)dev->base_addr;
-					*i = 0x21;
-					dev->mem_end =
-						dev->mem_start +
-						mac8390_memsize(dev->mem_start);
-					break;
-
-				default:
-					printk(KERN_ERR "Card type %s is"
-					       " unsupported, sorry\n",
-					       ndev->board->name);
-					continue;
+			case MAC8390_KINETICS:
+			case MAC8390_DAYNA: /* it's the same */
+				dev->base_addr =
+					(int)(ndev->board->slot_addr +
+					      DAYNA_8390_BASE);
+				dev->mem_start =
+					(int)(ndev->board->slot_addr +
+					      DAYNA_8390_MEM);
+				dev->mem_end =
+					dev->mem_start +
+					mac8390_memsize(dev->mem_start);
+				break;
+			case MAC8390_INTERLAN:
+				dev->base_addr =
+					(int)(ndev->board->slot_addr +
+					      INTERLAN_8390_BASE);
+				dev->mem_start =
+					(int)(ndev->board->slot_addr +
+					      INTERLAN_8390_MEM);
+				dev->mem_end =
+					dev->mem_start +
+					mac8390_memsize(dev->mem_start);
+				break;
+			case MAC8390_CABLETRON:
+				dev->base_addr =
+					(int)(ndev->board->slot_addr +
+					      CABLETRON_8390_BASE);
+				dev->mem_start =
+					(int)(ndev->board->slot_addr +
+					      CABLETRON_8390_MEM);
+				/* The base address is unreadable if 0x00
+				 * has been written to the command register
+				 * Reset the chip by writing E8390_NODMA +
+				 *   E8390_PAGE0 + E8390_STOP just to be
+				 *   sure
+				 */
+				i = (void *)dev->base_addr;
+				*i = 0x21;
+				dev->mem_end =
+					dev->mem_start +
+					mac8390_memsize(dev->mem_start);
+				break;
+
+			default:
+				printk(KERN_ERR "Card type %s is"
+				       " unsupported, sorry\n",
+				       ndev->board->name);
+				continue;
 			}
 		}
 
@@ -540,33 +540,33 @@ static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * nd
 	}
 
 	/* Fill in model-specific information and functions */
-	switch(type) {
+	switch (type) {
 	case MAC8390_FARALLON:
 	case MAC8390_APPLE:
-		switch(mac8390_testio(dev->mem_start)) {
-			case ACCESS_UNKNOWN:
-				printk("Don't know how to access card memory!\n");
-				return -ENODEV;
-				break;
+		switch (mac8390_testio(dev->mem_start)) {
+		case ACCESS_UNKNOWN:
+			printk("Don't know how to access card memory!\n");
+			return -ENODEV;
+			break;
 
-			case ACCESS_16:
-				/* 16 bit card, register map is reversed */
-				ei_status.reset_8390 = &mac8390_no_reset;
-				ei_status.block_input = &slow_sane_block_input;
-				ei_status.block_output = &slow_sane_block_output;
-				ei_status.get_8390_hdr = &slow_sane_get_8390_hdr;
-				ei_status.reg_offset = back4_offsets;
-				break;
+		case ACCESS_16:
+			/* 16 bit card, register map is reversed */
+			ei_status.reset_8390 = &mac8390_no_reset;
+			ei_status.block_input = &slow_sane_block_input;
+			ei_status.block_output = &slow_sane_block_output;
+			ei_status.get_8390_hdr = &slow_sane_get_8390_hdr;
+			ei_status.reg_offset = back4_offsets;
+			break;
 
-			case ACCESS_32:
-				/* 32 bit card, register map is reversed */
-				ei_status.reset_8390 = &mac8390_no_reset;
-				ei_status.block_input = &sane_block_input;
-				ei_status.block_output = &sane_block_output;
-				ei_status.get_8390_hdr = &sane_get_8390_hdr;
-				ei_status.reg_offset = back4_offsets;
-				access_bitmode = 1;
-				break;
+		case ACCESS_32:
+			/* 32 bit card, register map is reversed */
+			ei_status.reset_8390 = &mac8390_no_reset;
+			ei_status.block_input = &sane_block_input;
+			ei_status.block_output = &sane_block_output;
+			ei_status.get_8390_hdr = &sane_get_8390_hdr;
+			ei_status.reg_offset = back4_offsets;
+			access_bitmode = 1;
+			break;
 		}
 		break;
 
-- 
1.6.6.rc0.57.gad7a


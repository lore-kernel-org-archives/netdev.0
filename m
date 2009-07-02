From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [net-next-2.6 PATCH 4/9] vxge: Corrected Register map entry for
 xmac_link registers
Date: Thu, 2 Jul 2009 03:14:57 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10907020314120.13763-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, support@neterion.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:37773 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbZGBH0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 03:26:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Corrected Register map entry for xmac_link registers.

Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_3/drivers/net/vxge/vxge-reg.h patch_4/drivers/net/vxge/vxge-reg.h
--- patch_3/drivers/net/vxge/vxge-reg.h	2009-06-21 23:46:49.000000000 -0700
+++ patch_4/drivers/net/vxge/vxge-reg.h	2009-06-22 00:05:06.000000000 -0700
@@ -1784,7 +1784,7 @@ struct vxge_hw_mrpcim_reg {
 #define	VXGE_HW_XMAC_GEN_ERR_REG_XMACJ_XMAC_FSM_ERR	vxge_mBIT(63)
 /*0x01e18*/	u64	xmac_gen_err_mask;
 /*0x01e20*/	u64	xmac_gen_err_alarm;
-/*0x01e28*/	u64	xmac_link_err_port_reg[2];
+/*0x01e28*/	u64	xmac_link_err_port0_reg;
 #define	VXGE_HW_XMAC_LINK_ERR_PORT_REG_XMACJ_PORT_DOWN	vxge_mBIT(3)
 #define	VXGE_HW_XMAC_LINK_ERR_PORT_REG_XMACJ_PORT_UP	vxge_mBIT(7)
 #define	VXGE_HW_XMAC_LINK_ERR_PORT_REG_XMACJ_PORT_WENT_DOWN	vxge_mBIT(11)
@@ -1798,8 +1798,11 @@ struct vxge_hw_mrpcim_reg {
 #define	VXGE_HW_XMAC_LINK_ERR_PORT_REG_RATEMGMT_LASI_INV	vxge_mBIT(39)
 #define	VXGE_HW_XMAC_LINK_ERR_PORT_REG_XMDIO_MDIO_MGR_ACCESS_COMPLETE \
 								vxge_mBIT(47)
-/*0x01e30*/	u64	xmac_link_err_port_mask[2];
-/*0x01e38*/	u64	xmac_link_err_port_alarm[2];
+/*0x01e30*/	u64	xmac_link_err_port0_mask;
+/*0x01e38*/	u64	xmac_link_err_port0_alarm;
+/*0x01e40*/	u64	xmac_link_err_port1_reg;
+/*0x01e48*/	u64	xmac_link_err_port1_mask;
+/*0x01e50*/	u64	xmac_link_err_port1_alarm;
 /*0x01e58*/	u64	xgxs_gen_err_reg;
 #define	VXGE_HW_XGXS_GEN_ERR_REG_XGXS_XGXS_FSM_ERR	vxge_mBIT(63)
 /*0x01e60*/	u64	xgxs_gen_err_mask;


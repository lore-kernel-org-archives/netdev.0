From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net: sxgbe: remove duplicate SXGBE_CORE_L34_ADDCTL_REG define
Date: Mon, 9 Jun 2014 18:09:01 +0300
Message-ID: <20140609150901.GC9600@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Girish K S <ks.giri@samsung.com>,
	Vipul Pandya <vipul.pandya@samsung.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41420 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932778AbaFIPJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 11:09:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SXGBE_CORE_L34_ADDCTL_REG define is cut and pasted twice so we can
delete the second instance.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
index 56f8bf5..81437d9 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_reg.h
@@ -188,7 +188,6 @@
 
 /* L3/L4 function registers */
 #define SXGBE_CORE_L34_ADDCTL_REG	0x0C00
-#define SXGBE_CORE_L34_ADDCTL_REG	0x0C00
 #define SXGBE_CORE_L34_DATA_REG		0x0C04
 
 /* ARP registers */

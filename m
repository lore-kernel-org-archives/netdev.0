From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 1/12] forcedeth: dma access
Date: Tue, 09 Jan 2007 13:30:02 -0500
Message-ID: <45A3DF2A.5090004@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040202040500020304000406"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:2224 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932400AbXAIVXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:23:40 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040202040500020304000406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch allows the hardware to fetch the tx and rx ring descriptors 
with 64 bytes per access instead of 32 bytes.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------040202040500020304000406
Content-Type: text/plain;
 name="patch-prd-fetch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-prd-fetch"

--- orig/drivers/net/forcedeth.c	2007-01-07 15:10:15.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-07 15:10:28.000000000 -0500
@@ -304,8 +304,8 @@
 #define NVREG_TXRXCTL_RESET	0x0010
 #define NVREG_TXRXCTL_RXCHECK	0x0400
 #define NVREG_TXRXCTL_DESC_1	0
-#define NVREG_TXRXCTL_DESC_2	0x02100
-#define NVREG_TXRXCTL_DESC_3	0x02200
+#define NVREG_TXRXCTL_DESC_2	0x002100
+#define NVREG_TXRXCTL_DESC_3	0xc02200
 #define NVREG_TXRXCTL_VLANSTRIP 0x00040
 #define NVREG_TXRXCTL_VLANINS	0x00080
 	NvRegTxRingPhysAddrHigh = 0x148,

--------------040202040500020304000406--

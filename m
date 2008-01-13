From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 4/5] forcedeth: tx pause fix
Date: Sun, 13 Jan 2008 16:03:01 -0500
Message-ID: <478A7C85.2040004@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080600080400080607040106"
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:9220 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753609AbYANWtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 17:49:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080600080400080607040106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch fixes the tx pause enable watermark flags. The new values 
where determined to be optimal during testing.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------080600080400080607040106
Content-Type: text/plain;
 name="patch-forcedeth-txpause"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-txpause"

--- old/drivers/net/forcedeth.c	2008-01-13 15:12:16.000000000 -0500
+++ new/drivers/net/forcedeth.c	2008-01-13 15:14:55.000000000 -0500
@@ -316,8 +316,8 @@
 	NvRegTxRingPhysAddrHigh = 0x148,
 	NvRegRxRingPhysAddrHigh = 0x14C,
 	NvRegTxPauseFrame = 0x170,
-#define NVREG_TX_PAUSEFRAME_DISABLE	0x1ff0080
-#define NVREG_TX_PAUSEFRAME_ENABLE	0x0c00030
+#define NVREG_TX_PAUSEFRAME_DISABLE	0x01ff0080
+#define NVREG_TX_PAUSEFRAME_ENABLE	0x01800010
 	NvRegMIIStatus = 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008

--------------080600080400080607040106--

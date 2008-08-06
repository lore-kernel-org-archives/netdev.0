From: Li Yang <leoli@freescale.com>
Subject: [PATCH] net/fs_enet: remove redundant messages for performance
Date: Wed,  6 Aug 2008 15:08:50 +0800
Message-ID: <1218006530-27173-1-git-send-email-leoli@freescale.com>
Cc: linuxppc-dev@ozlabs.org, Li Yang <leoli@freescale.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:43726 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbYHFGyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 02:54:10 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m766s0hg003844
	for <netdev@vger.kernel.org>; Tue, 5 Aug 2008 23:54:05 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m766rxmK006486
	for <netdev@vger.kernel.org>; Wed, 6 Aug 2008 01:54:00 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently when we do a packet flood to the Ethernet port, the console
reports error every time when a packet is dropped.  This is too
redundant and cost performance.  Remove message for this type of event.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/fs_enet/mac-fcc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/fs_enet/mac-fcc.c
index 0a97fc2..1c7ef81 100644
--- a/drivers/net/fs_enet/mac-fcc.c
+++ b/drivers/net/fs_enet/mac-fcc.c
@@ -126,7 +126,7 @@ out:
 #define FCC_NAPI_RX_EVENT_MSK	(FCC_ENET_RXF | FCC_ENET_RXB)
 #define FCC_RX_EVENT		(FCC_ENET_RXF)
 #define FCC_TX_EVENT		(FCC_ENET_TXB)
-#define FCC_ERR_EVENT_MSK	(FCC_ENET_TXE | FCC_ENET_BSY)
+#define FCC_ERR_EVENT_MSK	(FCC_ENET_TXE)
 
 static int setup_data(struct net_device *dev)
 {
-- 
1.5.5.1.248.g4b17


From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 1/3] vxge: remove unnecessary printks
Date: Mon, 29 Nov 2010 22:02:45 -0600
Message-ID: <1291089767-18864-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34035 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab0K3ECy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 23:02:54 -0500
Received: by gyb11 with SMTP id 11so2479708gyb.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 20:02:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove printks for ring blocks, fifo blocks, and rx doorbell mode as
they clutter the dmesg output during modprobe and provide no useful
information.

Signed-off-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/vxge/vxge-main.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index a21dae1..44129c3 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3922,9 +3922,6 @@ static void __devinit vxge_print_parm(struct vxgedev *vdev, u64 vpath_mask)
 		vxge_debug_init(VXGE_TRACE,
 			"%s: MAC Address learning enabled", vdev->ndev->name);
 
-	vxge_debug_init(VXGE_TRACE,
-		"%s: Rx doorbell mode enabled", vdev->ndev->name);
-
 	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
 		if (!vxge_bVALn(vpath_mask, i, 1))
 			continue;
@@ -3937,14 +3934,6 @@ static void __devinit vxge_print_parm(struct vxgedev *vdev, u64 vpath_mask)
 			((struct __vxge_hw_device  *)(vdev->devh))->
 				config.vp_config[i].rpa_strip_vlan_tag
 			? "Enabled" : "Disabled");
-		vxge_debug_init(VXGE_TRACE,
-			"%s: Ring blocks : %d", vdev->ndev->name,
-			((struct __vxge_hw_device  *)(vdev->devh))->
-				config.vp_config[i].ring.ring_blocks);
-		vxge_debug_init(VXGE_TRACE,
-			"%s: Fifo blocks : %d", vdev->ndev->name,
-			((struct __vxge_hw_device  *)(vdev->devh))->
-				config.vp_config[i].fifo.fifo_blocks);
 		vxge_debug_ll_config(VXGE_TRACE,
 			"%s: Max frags : %d", vdev->ndev->name,
 			((struct __vxge_hw_device  *)(vdev->devh))->
-- 
1.7.0.4


From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [net] r8169   Remove duplicate command which set RxVlan and RxChksum bits.
Date: Sun, 31 Jan 2016 17:33:08 +0200
Message-ID: <1454254388-15523-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [82.78.245.184] ([82.78.245.184]:55414 "EHLO marian1000.go.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932361AbcAaPdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jan 2016 10:33:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 These bits is already set on set geatures stage.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 17d5571..a8fb86d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8368,7 +8368,6 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 		NETIF_F_HIGHDMA;
 
-	tp->cp_cmd |= RxChkSum | RxVlan;
 
 	/*
 	 * Pretend we are using VLANs; This bypasses a nasty bug where
-- 
2.5.0

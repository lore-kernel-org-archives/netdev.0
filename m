From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 23/30] bna: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:27:48 +0200
Message-ID: <1405866475-24754-4-git-send-email-fabf@skynet.be>
References: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Rasesh Mody <rmody@brocade.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/brocade/bna/cna_fwimg.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/cna_fwimg.c b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
index 6a68e8d..6f72771 100644
--- a/drivers/net/ethernet/brocade/bna/cna_fwimg.c
+++ b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
@@ -68,10 +68,8 @@ bfa_cb_image_get_chunk(enum bfi_asic_gen asic_gen, u32 off)
 	switch (asic_gen) {
 	case BFI_ASIC_GEN_CT:
 		return (bfi_image_ct_cna + off);
-		break;
 	case BFI_ASIC_GEN_CT2:
 		return (bfi_image_ct2_cna + off);
-		break;
 	default:
 		return NULL;
 	}
@@ -83,10 +81,8 @@ bfa_cb_image_get_size(enum bfi_asic_gen asic_gen)
 	switch (asic_gen) {
 	case BFI_ASIC_GEN_CT:
 		return bfi_image_ct_cna_size;
-		break;
 	case BFI_ASIC_GEN_CT2:
 		return bfi_image_ct2_cna_size;
-		break;
 	default:
 		return 0;
 	}
-- 
1.9.1

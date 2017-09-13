From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 06/10] drivers:ethernet: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 13:02:15 +0530
Message-ID: <1505287939-14106-6-git-send-email-allen.lkml@gmail.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Cc: nouveau@lists.freedesktop.org, linux-crypto@vger.kernel.org,
        dri-devel@lists.freedesktop.org, MPT-FusionLinux.pdl@broadcom.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        megaraidlinux.pdl@broadcom.com, target-devel@vger.kernel.org,
        linux-fbdev@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/ethernet/sun/cassini.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index 382993c..fc0ea3a 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -3984,7 +3984,7 @@ static inline int cas_alloc_rx_desc(struct cas *cp, int ring)
 	size = RX_DESC_RINGN_SIZE(ring);
 	for (i = 0; i < size; i++) {
 		if ((page[i] = cas_page_alloc(cp, GFP_KERNEL)) == NULL)
-			return -1;
+			return -ENOMEM;
 	}
 	return 0;
 }
-- 
2.7.4

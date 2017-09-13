From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 03/10] driver:gpu: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 13:02:12 +0530
Message-ID: <1505287939-14106-3-git-send-email-allen.lkml@gmail.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Cc: nouveau@lists.freedesktop.org, linux-crypto@vger.kernel.org,
        dri-devel@lists.freedesktop.org, MPT-FusionLinux.pdl@broadcom.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        megaraidlinux.pdl@broadcom.com, target-devel@vger.kernel.org,
        linux-fbdev@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/gpu/drm/gma500/mid_bios.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/gma500/mid_bios.c b/drivers/gpu/drm/gma500/mid_bios.c
index d75ecb3..1fa1633 100644
--- a/drivers/gpu/drm/gma500/mid_bios.c
+++ b/drivers/gpu/drm/gma500/mid_bios.c
@@ -237,7 +237,7 @@ static int mid_get_vbt_data_r10(struct drm_psb_private *dev_priv, u32 addr)
 
 	gct = kmalloc(sizeof(*gct) * vbt.panel_count, GFP_KERNEL);
 	if (!gct)
-		return -1;
+		return -ENOMEM;
 
 	gct_virtual = ioremap(addr + sizeof(vbt),
 			sizeof(*gct) * vbt.panel_count);
-- 
2.7.4

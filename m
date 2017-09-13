From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 09/10] driver:video: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 13:02:18 +0530
Message-ID: <1505287939-14106-9-git-send-email-allen.lkml@gmail.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Cc: nouveau@lists.freedesktop.org, linux-crypto@vger.kernel.org,
        dri-devel@lists.freedesktop.org, MPT-FusionLinux.pdl@broadcom.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        megaraidlinux.pdl@broadcom.com, target-devel@vger.kernel.org,
        linux-fbdev@vger.kernel.org, linux-btrfs@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/video/fbdev/matrox/matroxfb_base.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/video/fbdev/matrox/matroxfb_base.c b/drivers/video/fbdev/matrox/matroxfb_base.c
index f6a0b9a..5cd238d 100644
--- a/drivers/video/fbdev/matrox/matroxfb_base.c
+++ b/drivers/video/fbdev/matrox/matroxfb_base.c
@@ -2058,7 +2058,7 @@ static int matroxfb_probe(struct pci_dev* pdev, const struct pci_device_id* dumm
 
 	minfo = kzalloc(sizeof(*minfo), GFP_KERNEL);
 	if (!minfo)
-		return -1;
+		return -ENOMEM;
 
 	minfo->pcidev = pdev;
 	minfo->dead = 0;
-- 
2.7.4

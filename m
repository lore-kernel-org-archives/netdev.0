From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 10/10] fs:btrfs: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 13:02:19 +0530
Message-ID: <1505287939-14106-10-git-send-email-allen.lkml@gmail.com>
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
 fs/btrfs/check-integrity.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index 7d5a9b5..efa4c23 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -2913,7 +2913,7 @@ int btrfsic_mount(struct btrfs_fs_info *fs_info,
 	state = kvzalloc(sizeof(*state), GFP_KERNEL);
 	if (!state) {
 		pr_info("btrfs check-integrity: allocation failed!\n");
-		return -1;
+		return -ENOMEM;
 	}
 
 	if (!btrfsic_is_initialized) {
-- 
2.7.4

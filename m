From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 02/10] drivers:crypto: return -ENOMEM on allocation failure.
Date: Wed, 13 Sep 2017 13:02:11 +0530
Message-ID: <1505287939-14106-2-git-send-email-allen.lkml@gmail.com>
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
 drivers/crypto/omap-aes-gcm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/crypto/omap-aes-gcm.c b/drivers/crypto/omap-aes-gcm.c
index 7d4f8a4..2542224 100644
--- a/drivers/crypto/omap-aes-gcm.c
+++ b/drivers/crypto/omap-aes-gcm.c
@@ -186,7 +186,7 @@ static int do_encrypt_iv(struct aead_request *req, u32 *tag, u32 *iv)
 	sk_req = skcipher_request_alloc(ctx->ctr, GFP_KERNEL);
 	if (!sk_req) {
 		pr_err("skcipher: Failed to allocate request\n");
-		return -1;
+		return -ENOMEM;
 	}
 
 	init_completion(&result.completion);
-- 
2.7.4

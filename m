From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/2] ath6kl: Remove trailing unpaired close paren from ath6kl_err uses
Date: Sun, 17 Jul 2011 14:38:57 -0700
Message-ID: <6a83ad0030e3b0495468d8fcc44bb6cd913baa9f.1310938421.git.joe@perches.com>
References: <4E2349D4.4000204@qca.qualcomm.com>
Cc: devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org, error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E2349D4.4000204-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
In-Reply-To: <cover.1310938421.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
References: <cover.1310938421.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Unpaired parentheses are unsightly.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/ath/ath6kl/sdio.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/sdio.c b/drivers/net/wireless/ath/ath6kl/sdio.c
index c58a107..e399b17 100644
--- a/drivers/net/wireless/ath/ath6kl/sdio.c
+++ b/drivers/net/wireless/ath/ath6kl/sdio.c
@@ -511,7 +511,7 @@ static int ath6kl_sdio_power_on(struct ath6kl_sdio *ar_sdio)
 
 	ret = sdio_enable_func(func);
 	if (ret) {
-		ath6kl_err("Unable to enable sdio func: %d)\n", ret);
+		ath6kl_err("Unable to enable sdio func: %d\n", ret);
 		sdio_release_host(func);
 		return ret;
 	}
@@ -760,7 +760,7 @@ static int ath6kl_sdio_probe(struct sdio_func *func,
 
 	ret = sdio_set_block_size(func, HIF_MBOX_BLOCK_SIZE);
 	if (ret) {
-		ath6kl_err("Set sdio block size %d failed: %d)\n",
+		ath6kl_err("Set sdio block size %d failed: %d\n",
 			   HIF_MBOX_BLOCK_SIZE, ret);
 		sdio_release_host(func);
 		goto err_off;
-- 
1.7.6.131.g99019

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

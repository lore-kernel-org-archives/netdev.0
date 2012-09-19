From: Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
Subject: [PATCH 1/2] Added information about which firmware file is being requested.
Date: Wed, 19 Sep 2012 13:18:12 +0200
Message-ID: <1348053493-22955-1-git-send-email-jarl@softace.dk>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
To: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>,
	=?UTF-8?q?G=C3=A1bor=20Stefanik?= <netrolller.3d-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is informative information to provide about which actual firmware
file is being used.

Signed-off-by: Jarl Friis <jarl-bE7lSbLpGj1/SzgSGea1oA@public.gmane.org>
---
 drivers/net/wireless/b43/main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index a140165..202a0eb 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2131,6 +2131,7 @@ int b43_do_request_fw(struct b43_request_fw_context *ctx,
 		B43_WARN_ON(1);
 		return -ENOSYS;
 	}
+	b43info(ctx->dev->wl, "Requesting firmware file '%s'\n", ctx->fwname);
 	err = request_firmware(&blob, ctx->fwname, ctx->dev->dev->dev);
 	if (err == -ENOENT) {
 		snprintf(ctx->errors[ctx->req_type],
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

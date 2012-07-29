From: Devendra Naga <develkernel412222@gmail.com>
Subject: [PATCH] bnx2x: remove cast around the kmalloc in bnx2x_prev_mark_path
Date: Sun, 29 Jul 2012 19:04:23 +0545
Message-ID: <1343567963-12389-1-git-send-email-develkernel412222@gmail.com>
Cc: Devendra Naga <develkernel412222@gmail.com>
To: Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:56979 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab2G2NTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2012 09:19:32 -0400
Received: by pbbrp8 with SMTP id rp8so8154407pbb.19
        for <netdev@vger.kernel.org>; Sun, 29 Jul 2012 06:19:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

casting the void pointer is redundant (Documentation/CodingStyle)

Signed-off-by: Devendra Naga <develkernel412222@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9aaf863..dd451c3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9360,8 +9360,7 @@ static int __devinit bnx2x_prev_mark_path(struct bnx2x *bp)
 	struct bnx2x_prev_path_list *tmp_list;
 	int rc;
 
-	tmp_list = (struct bnx2x_prev_path_list *)
-		    kmalloc(sizeof(struct bnx2x_prev_path_list), GFP_KERNEL);
+	tmp_list = kmalloc(sizeof(struct bnx2x_prev_path_list), GFP_KERNEL);
 	if (!tmp_list) {
 		BNX2X_ERR("Failed to allocate 'bnx2x_prev_path_list'\n");
 		return -ENOMEM;
-- 
1.7.9.5

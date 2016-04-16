From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 1/6] nfp: check the right pointer for errors
Date: Sat, 16 Apr 2016 11:25:49 +0100
Message-ID: <1460802354-14248-2-git-send-email-jakub.kicinski@netronome.com>
References: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38186 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbcDPK0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 06:26:22 -0400
Received: by mail-wm0-f42.google.com with SMTP id u206so62615166wme.1
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 03:26:21 -0700 (PDT)
In-Reply-To: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct checking error condition on wrong pointer -
copy/paste mistake most likely.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index f86a1f13d27b..d77ae4d0e4dc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -200,7 +200,7 @@ void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
 
 	/* Create queue debugging sub-tree */
 	queues = debugfs_create_dir("queue", nn->debugfs_dir);
-	if (IS_ERR_OR_NULL(nn->debugfs_dir))
+	if (IS_ERR_OR_NULL(queues))
 		return;
 
 	rx = debugfs_create_dir("rx", queues);
-- 
1.9.1

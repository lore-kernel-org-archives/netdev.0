From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/6] nfp: remove unnecessary static
Date: Sat, 16 Apr 2016 11:25:50 +0100
Message-ID: <1460802354-14248-3-git-send-email-jakub.kicinski@netronome.com>
References: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37251 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751289AbcDPK02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 06:26:28 -0400
Received: by mail-wm0-f46.google.com with SMTP id n3so62927497wmn.0
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2016 03:26:27 -0700 (PDT)
In-Reply-To: <1460802354-14248-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no reason for those local variables to be static.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
index d77ae4d0e4dc..f7c9a5bc4aa3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -187,7 +187,7 @@ static const struct file_operations nfp_tx_q_fops = {
 
 void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
 {
-	static struct dentry *queues, *tx, *rx;
+	struct dentry *queues, *tx, *rx;
 	char int_name[16];
 	int i;
 
-- 
1.9.1

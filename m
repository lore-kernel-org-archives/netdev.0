From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH] net: wireless: libertas: debugfs.c: remove unnecessary check before calling debugfs_remove
Date: Wed, 11 Feb 2015 09:33:06 +0100
Message-ID: <1423643586-11002-1-git-send-email-baspeters93@gmail.com>
Cc: Bas Peters <baspeters93@gmail.com>, linville@tuxdriver.com,
	johannes.berg@intel.com, dcbw@redhat.com,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:56634 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442AbbBKIdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 03:33:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Debugfs_remove will check for error or NULL for us, so it is not
necessary to do this here.

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/net/wireless/libertas/debugfs.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index cc6a0a5..26cbf1d 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -742,8 +742,7 @@ void lbs_debugfs_init(void)
 
 void lbs_debugfs_remove(void)
 {
-	if (lbs_dir)
-		 debugfs_remove(lbs_dir);
+	debugfs_remove(lbs_dir);
 }
 
 void lbs_debugfs_init_one(struct lbs_private *priv, struct net_device *dev)
-- 
2.1.0

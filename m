From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] caif: remove unused struct member
Date: Tue, 31 Mar 2015 16:05:23 +0200
Message-ID: <1427810723-21234-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tty_name member of struct ser_device is never set or used, so it
can be removed. (The definition of struct ser_device is private to
this .c file, and the identifier tty_name only occurs in this one
place.)

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/caif/caif_serial.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 27bbc56de15f..9da06537237f 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -70,7 +70,6 @@ struct ser_device {
 	struct tty_struct *tty;
 	bool tx_started;
 	unsigned long state;
-	char *tty_name;
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *debugfs_tty_dir;
 	struct debugfs_blob_wrapper tx_blob;
-- 
2.1.3

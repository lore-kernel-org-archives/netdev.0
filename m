From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 01/18] Bluetooth: Removal of unused variable in btmrvl driver
Date: Thu,  3 Dec 2009 19:45:38 +0100
Message-ID: <b3cf652afb5404685e3d7ed6780a8d1fa10e21da.1259865280.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:37643 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755767AbZLCSpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 13:45:55 -0500
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
In-Reply-To: <cover.1259865279.git.marcel@holtmann.org>
References: <cover.1259865279.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Tank <rahult@marvell.com>

This patch removes unused variable "drvdbg" from btmrvl_debugfs_data
structure.

Signed-off-by: Rahul Tank <rahult@marvell.com>
Signed-off-by: Bing Zhao <bzhao@marvell.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_debugfs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_debugfs.c b/drivers/bluetooth/btmrvl_debugfs.c
index 4617bd1..d43b5cb 100644
--- a/drivers/bluetooth/btmrvl_debugfs.c
+++ b/drivers/bluetooth/btmrvl_debugfs.c
@@ -29,7 +29,6 @@ struct btmrvl_debugfs_data {
 	struct dentry *root_dir, *config_dir, *status_dir;
 
 	/* config */
-	struct dentry *drvdbg;
 	struct dentry *psmode;
 	struct dentry *pscmd;
 	struct dentry *hsmode;
-- 
1.6.5.2


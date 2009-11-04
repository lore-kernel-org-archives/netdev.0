From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 11/12] wimax/i2400m: fix SDIO debugfs dentry name
Date: Wed,  4 Nov 2009 13:40:16 -0800
Message-ID: <20d57f8e2553fa6f5cd382131b7f18e91c7141fc.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28866 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932801AbZKDVmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:21 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SDIO specific debugfs dentry was being misnamed "i2400m-usb"
instead of "i2400m-sdio".

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index e8ad85c..b06d526 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -407,7 +407,7 @@ int i2400ms_debugfs_add(struct i2400ms *i2400ms)
 	int result;
 	struct dentry *dentry = i2400ms->i2400m.wimax_dev.debugfs_dentry;
 
-	dentry = debugfs_create_dir("i2400m-usb", dentry);
+	dentry = debugfs_create_dir("i2400m-sdio", dentry);
 	result = PTR_ERR(dentry);
 	if (IS_ERR(dentry)) {
 		if (result == -ENODEV)
-- 
1.6.2.5


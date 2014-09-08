From: roy.qing.li@gmail.com
Subject: [PATCH] btrfs: remove the wrong comments
Date: Mon,  8 Sep 2014 20:31:06 +0800
Message-ID: <1410179466-25409-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:58375 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911AbaIHMbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 08:31:08 -0400
Received: by mail-pd0-f170.google.com with SMTP id r10so20832584pdi.1
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 05:31:07 -0700 (PDT)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id ds14sm380916pdb.20.2014.09.08.05.31.06
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 05:31:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com> 

This comments became wrong after c3c532[bdi: add helper function for
doing init and register of a bdi for a file system], so remove them.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 fs/btrfs/disk-io.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index d0ed9e6..ce8b8b6 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -1703,10 +1703,6 @@ static int btrfs_congested_fn(void *congested_data, int bdi_bits)
 	return ret;
 }
 
-/*
- * If this fails, caller must call bdi_destroy() to get rid of the
- * bdi again.
- */
 static int setup_bdi(struct btrfs_fs_info *info, struct backing_dev_info *bdi)
 {
 	int err;
-- 
1.7.10.4

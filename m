From: roy.qing.li@gmail.com
Subject: [PATCH v2] vxlan: remove the dead codes
Date: Fri, 17 Oct 2014 14:04:04 +0800
Message-ID: <1413525844-2406-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:38656 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaJQGEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 02:04:09 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so192907pdj.12
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2014 23:04:09 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id dk7sm454455pdb.8.2014.10.16.23.04.07
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 16 Oct 2014 23:04:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

remove the dead codes, no user uses vxlan_salt

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/vxlan.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 77ab844..855a81d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -152,8 +152,6 @@ struct vxlan_dev {
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
 
-/* salt for hash table */
-static u32 vxlan_salt __read_mostly;
 static struct workqueue_struct *vxlan_wq;
 
 static void vxlan_sock_work(struct work_struct *work);
@@ -2797,8 +2795,6 @@ static int __init vxlan_init_module(void)
 	if (!vxlan_wq)
 		return -ENOMEM;
 
-	get_random_bytes(&vxlan_salt, sizeof(vxlan_salt));
-
 	rc = register_pernet_subsys(&vxlan_net_ops);
 	if (rc)
 		goto out1;
-- 
1.7.10.4

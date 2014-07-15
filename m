From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 10/12] bonding: convert bond_procfs.c to use netdev_printk instead of pr_
Date: Tue, 15 Jul 2014 19:36:07 +0200
Message-ID: <1405445769-15394-11-git-send-email-vfalico@gmail.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29279 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757528AbaGORkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:51 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_procfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index b215b47..de62c03 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -252,8 +252,8 @@ void bond_create_proc_entry(struct bonding *bond)
 						    S_IRUGO, bn->proc_dir,
 						    &bond_info_fops, bond);
 		if (bond->proc_entry == NULL)
-			pr_warn("Warning: Cannot create /proc/net/%s/%s\n",
-				DRV_NAME, bond_dev->name);
+			netdev_warn(bond_dev, "Cannot create /proc/net/%s/%s\n",
+				    DRV_NAME, bond_dev->name);
 		else
 			memcpy(bond->proc_file_name, bond_dev->name, IFNAMSIZ);
 	}
-- 
1.8.4

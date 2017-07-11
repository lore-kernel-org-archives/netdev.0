From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 09/10] net: bonding: constify attribute_group structures.
Date: Tue, 11 Jul 2017 13:06:01 +0530
Message-ID: <1499758561-24988-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1499758561-24988-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499758561-24988-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/netdevice.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   4512	   1472	      0	   5984	   1760	drivers/net/bonding/bond_sysfs.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   4576	   1408	      0	   5984	   1760	drivers/net/bonding/bond_sysfs.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              Added cover later.

 drivers/net/bonding/bond_sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 770623a..040b493 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -759,7 +759,7 @@ static DEVICE_ATTR(ad_user_port_key, S_IRUGO | S_IWUSR,
 	NULL,
 };
 
-static struct attribute_group bonding_group = {
+static const struct attribute_group bonding_group = {
 	.name = "bonding",
 	.attrs = per_bond_attrs,
 };
-- 
1.9.1

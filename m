From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v3 09/10] net: bonding: constify attribute_group structures.
Date: Tue, 18 Jul 2017 15:15:56 +0530
Message-ID: <1500371156-14878-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/netdevice.h> work
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
Changes in v3:
              net-next was closed. Now resubmitting it.

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

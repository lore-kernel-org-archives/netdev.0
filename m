From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: can: at91_can: constify attribute_group structures.
Date: Mon, 10 Jul 2017 13:31:27 +0530
Message-ID: <3ffbac2d582a6fe8f0d430dcf0bb313226aa1bcf.1499673562.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, llinux-can@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: wg@grandegger.com, mkl@pengutronix.de, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/netdevice.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   6164	    304	      0	   6468	   1944	drivers/net/can/at91_can.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   6228	    240	      0	   6468	   1944	drivers/net/can/at91_can.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/can/at91_can.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 0e0df0b..f37ce0e 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1232,7 +1232,7 @@ static DEVICE_ATTR(mb0_id, S_IWUSR | S_IRUGO,
 	NULL,
 };
 
-static struct attribute_group at91_sysfs_attr_group = {
+static const struct attribute_group at91_sysfs_attr_group = {
 	.attrs = at91_sysfs_attrs,
 };
 
-- 
1.9.1

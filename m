From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v3 02/10] net: can: at91_can: constify attribute_group structures.
Date: Tue, 18 Jul 2017 15:14:18 +0530
Message-ID: <1500371059-14678-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-can@vger.kernel.org
To: davem@davemloft.net, wg@grandegger.com, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/netdevice.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   6164	    304	      0	   6468	   1944	drivers/net/can/at91_can.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   6228	    240	      0	   6468	   1944	drivers/net/can/at91_can.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              Added cover later.
Changes in v3:
              net-next was closed. Now resubmitting it.

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

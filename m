From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: can: janz-ican3: constify attribute_group structures.
Date: Mon, 10 Jul 2017 13:34:20 +0530
Message-ID: <f240134a345851ae8b687a8c745ae302c97c3b0c.1499673829.git.arvind.yadav.cs@gmail.com>
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
  11800	    368	      0	  12168	   2f88	drivers/net/can/janz-ican3.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  11864	    304	      0	  12168	   2f88	drivers/net/can/janz-ican3.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/can/janz-ican3.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 2ba1a81..12a53c8 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1875,7 +1875,7 @@ static DEVICE_ATTR(termination, S_IWUSR | S_IRUGO, ican3_sysfs_show_term,
 	NULL,
 };
 
-static struct attribute_group ican3_sysfs_attr_group = {
+static const struct attribute_group ican3_sysfs_attr_group = {
 	.attrs = ican3_sysfs_attrs,
 };
 
-- 
1.9.1

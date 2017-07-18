From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v3 03/10] net: can: janz-ican3: constify attribute_group structures.
Date: Tue, 18 Jul 2017 15:14:19 +0530
Message-ID: <1500371059-14678-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1500371059-14678-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-can@vger.kernel.org
To: davem@davemloft.net, wg@grandegger.com, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500371059-14678-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/netdevice.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  11800	    368	      0	  12168	   2f88	drivers/net/can/janz-ican3.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  11864	    304	      0	  12168	   2f88	drivers/net/can/janz-ican3.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              Added cover later.
Changes in v3:
              net-next was closed. Now resubmitting it.

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

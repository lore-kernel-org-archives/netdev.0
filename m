From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: cdc_ncm: constify attribute_group structures.
Date: Mon, 10 Jul 2017 13:25:47 +0530
Message-ID: <40d71c9c561fa69b42ef43c40df75538e25e4a66.1499673283.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: oliver@neukum.org, bjorn@mork.no, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/netdevice.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  13275	    928	      1	  14204	   377c	drivers/net/usb/cdc_ncm.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  13339	    864	      1	  14204	   377c	drivers/net/usb/cdc_ncm.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index d103a1d..b401ba9 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -367,7 +367,7 @@ static DEVICE_ATTR(name, S_IRUGO, cdc_ncm_show_##name, NULL)
 	NULL,
 };
 
-static struct attribute_group cdc_ncm_sysfs_attr_group = {
+static const struct attribute_group cdc_ncm_sysfs_attr_group = {
 	.name = "cdc_ncm",
 	.attrs = cdc_ncm_sysfs_attrs,
 };
-- 
1.9.1

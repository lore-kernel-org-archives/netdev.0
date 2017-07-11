From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 08/10] arcnet: com20020-pci: constify attribute_group structures.
Date: Tue, 11 Jul 2017 13:04:18 +0530
Message-ID: <1499758458-24920-2-git-send-email-arvind.yadav.cs@gmail.com>
References: <1499758458-24920-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m.grzeschik@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499758458-24920-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/netdevice.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
   3409	    948	     28	   4385	   1121	drivers/net/arcnet/com20020-pci.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
   3473	    884	     28	   4385	   1121	drivers/net/arcnet/com20020-pci.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
Changes in v2:
              Added cover later.

 drivers/net/arcnet/com20020-pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index 01cab95..eb7f767 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -109,7 +109,7 @@ static ssize_t backplane_mode_show(struct device *dev,
 	NULL,
 };
 
-static struct attribute_group com20020_state_group = {
+static const struct attribute_group com20020_state_group = {
 	.name = NULL,
 	.attrs = com20020_state_attrs,
 };
-- 
1.9.1

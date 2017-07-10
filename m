From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] arcnet: com20020-pci: constify attribute_group structures.
Date: Mon, 10 Jul 2017 15:35:45 +0530
Message-ID: <380810ace8ad6a9b2ecb35dfc647a1196eb40da2.1499681020.git.arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m.grzeschik@pengutronix.de, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
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

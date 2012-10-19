From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 09/21] of: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 21:14:13 -0700
Message-ID: <898fbb8148dc43347373e827fbb7a78279e8a2c0.1350618011.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/of/of_net.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/of/of_net.c b/drivers/of/of_net.c
index ffab033..452dcf6 100644
--- a/drivers/of/of_net.c
+++ b/drivers/of/of_net.c
@@ -78,15 +78,15 @@ const void *of_get_mac_address(struct device_node *np)
 	struct property *pp;
 
 	pp = of_find_property(np, "mac-address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
+	if (pp && (pp->length == 6) && eth_addr_valid(pp->value))
 		return pp->value;
 
 	pp = of_find_property(np, "local-mac-address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
+	if (pp && (pp->length == 6) && eth_addr_valid(pp->value))
 		return pp->value;
 
 	pp = of_find_property(np, "address", NULL);
-	if (pp && (pp->length == 6) && is_valid_ether_addr(pp->value))
+	if (pp && (pp->length == 6) && eth_addr_valid(pp->value))
 		return pp->value;
 
 	return NULL;
-- 
1.7.8.111.gad25c.dirty

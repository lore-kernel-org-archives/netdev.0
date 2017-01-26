From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/5] gtp: Improve another size determination in ipv4_pdp_add()
Date: Thu, 26 Jan 2017 11:18:09 +0100
Message-ID: <91f31650-3052-507c-8006-96874107f981@users.sourceforge.net>
References: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Harald Welte <laforge@gnumonks.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Pablo Neira <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <698070a4-e08e-78e5-0214-df69783cce22@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 25 Jan 2017 22:24:08 +0100

Replace the specification of a data type by a pointer dereference
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/gtp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 5d0d520ae40f..f0c123101aa9 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -956,7 +956,7 @@ static int ipv4_pdp_add(struct net_device *dev, struct genl_info *info)
 
 	}
 
-	pctx = kmalloc(sizeof(struct pdp_ctx), GFP_KERNEL);
+	pctx = kmalloc(sizeof(*pctx), GFP_KERNEL);
 	if (pctx == NULL)
 		return -ENOMEM;
 
-- 
2.11.0

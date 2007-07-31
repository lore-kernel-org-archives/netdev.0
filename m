From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH 69] drivers/net/sb1250-mac.c: kmalloc + memset conversion to kcalloc
Date: Tue, 31 Jul 2007 23:58:36 +0200
Message-ID: <200707312358.36567.m.kozlowski@tuxland.pl>
References: <200707311845.48807.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <200707311845.48807.m.kozlowski@tuxland.pl>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/sb1250-mac.c | 76286 -> 76199 (-87 bytes)

 drivers/net/sb1250-mac.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

--- linux-2.6.23-rc1-mm1-a/drivers/net/sb1250-mac.c	2007-07-26 13:07:43.000000000 +0200
+++ linux-2.6.23-rc1-mm1-b/drivers/net/sb1250-mac.c	2007-07-31 13:46:10.000000000 +0200
@@ -779,10 +779,8 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 * And context table
 	 */

-	d->sbdma_ctxtable = (struct sk_buff **)
-		kmalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
-
-	memset(d->sbdma_ctxtable,0,d->sbdma_maxdescr*sizeof(struct sk_buff *));
+	d->sbdma_ctxtable = kcalloc(d->sbdma_maxdescr,
+				    sizeof(struct sk_buff *), GFP_KERNEL);

 #ifdef CONFIG_SBMAC_COALESCE
 	/*

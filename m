From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/10] drivers/net/davinci_emac.c: Fix continuation line formats
Date: Mon,  1 Feb 2010 23:22:11 -0800
Message-ID: <0bcecb6f7b478b564d700dbb7f4344616fcb6bec.1265095094.git.joe@perches.com>
References: <cover.1265095093.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265095093.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

String constants that are continued on subsequent lines with \
are not good.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/davinci_emac.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 33c4fe2..faffad4 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2672,8 +2672,7 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	priv->emac_base_phys = res->start + pdata->ctrl_reg_offset;
 	size = res->end - res->start + 1;
 	if (!request_mem_region(res->start, size, ndev->name)) {
-		dev_err(emac_dev, "DaVinci EMAC: failed request_mem_region() \
-					 for regs\n");
+		dev_err(emac_dev, "DaVinci EMAC: failed request_mem_region() for regs\n");
 		rc = -ENXIO;
 		goto probe_quit;
 	}
-- 
1.6.6.rc0.57.gad7a

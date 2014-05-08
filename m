From: George Cherian <george.cherian@ti.com>
Subject: [PATCH v2 2/3] net: davinci_mdio: Convert pr_err() to dev_err() call
Date: Thu, 8 May 2014 15:20:51 +0530
Message-ID: <1399542652-14900-3-git-send-email-george.cherian@ti.com>
References: <1399542652-14900-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>, <balbi@ti.com>,
	<zonque@gmail.com>, <mpa@pengutronix.de>, <tklauser@distanz.ch>,
	George Cherian <george.cherian@ti.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399542652-14900-1-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the lone pr_err() to dev_err() call.
Also, Convert kzalloc to devm_kzalloc.

Signed-off-by: George Cherian <george.cherian@ti.com>
Reviewed-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 34e97ec..735dc53 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -303,7 +303,7 @@ static int davinci_mdio_probe_dt(struct mdio_platform_data *data,
 		return -EINVAL;
 
 	if (of_property_read_u32(node, "bus_freq", &prop)) {
-		pr_err("Missing bus_freq property in the DT.\n");
+		dev_err(&pdev->dev, "Missing bus_freq property in the DT.\n");
 		return -EINVAL;
 	}
 	data->bus_freq = prop;
-- 
1.8.3.1

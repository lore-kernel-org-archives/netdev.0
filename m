From: Greentime Hu <green.hu@gmail.com>
Subject: [PATCH v2] net: ethernet: faraday: To support device tree usage.
Date: Wed, 16 Nov 2016 20:03:46 +0800
Message-ID: <1479297826-4335-1-git-send-email-green.hu@gmail.com>
Cc: Greentime Hu <green.hu@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jiri@resnulli.us
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Greentime Hu <green.hu@gmail.com>
---
 drivers/net/ethernet/faraday/ftmac100.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index dce5f7b..5d70ee9 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1172,11 +1172,17 @@ static int __exit ftmac100_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static const struct of_device_id ftmac100_of_ids[] = {
+	{ .compatible = "andestech,atmac100" },
+	{ }
+};
+
 static struct platform_driver ftmac100_driver = {
 	.probe		= ftmac100_probe,
 	.remove		= __exit_p(ftmac100_remove),
 	.driver		= {
 		.name	= DRV_NAME,
+		.of_match_table = ftmac100_of_ids
 	},
 };
 
@@ -1200,3 +1206,4 @@ static void __exit ftmac100_exit(void)
 MODULE_AUTHOR("Po-Yu Chuang <ratbert@faraday-tech.com>");
 MODULE_DESCRIPTION("FTMAC100 driver");
 MODULE_LICENSE("GPL");
+MODULE_DEVICE_TABLE(of, ftmac100_of_ids);
-- 
1.7.9.5

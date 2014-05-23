From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH v2 4/4] net: ks8851: Add of match table
Date: Fri, 23 May 2014 12:57:20 -0700
Message-ID: <1400875040-13269-5-git-send-email-sboyd@codeaurora.org>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Users are currently just providing "ks8851" as the compatible for
this driver in device tree. Add a compatible string that provides
the vendor name along with the device name to be more explicit.

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---
 drivers/net/ethernet/micrel/ks8851.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 3a322daba5ff..e72918970a58 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1603,9 +1603,15 @@ static int ks8851_remove(struct spi_device *spi)
 	return 0;
 }
 
+static const struct of_device_id ks8851_match_table[] = {
+	{ .compatible = "micrel,ks8851" },
+	{ }
+};
+
 static struct spi_driver ks8851_driver = {
 	.driver = {
 		.name = "ks8851",
+		.of_match_table = ks8851_match_table,
 		.owner = THIS_MODULE,
 		.pm = &ks8851_pm_ops,
 	},
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

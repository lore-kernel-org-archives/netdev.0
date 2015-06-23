From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: [PATCH 5/6] wireless: cw1200: Remove redundant spi driver bus initialization
Date: Tue, 23 Jun 2015 22:53:05 +0800
Message-ID: <1435071185-24586-1-git-send-email-borneo.antonio@gmail.com>
References: <1435070714-24174-1-git-send-email-borneo.antonio@gmail.com>
Cc: Antonio Borneo <borneo.antonio@gmail.com>,
	linux-kernel@vger.kernel.org
To: Solomon Peachy <pizza@shaftnet.org>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435070714-24174-1-git-send-email-borneo.antonio@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In ancient times it was necessary to manually initialize the bus
field of an spi_driver to spi_bus_type. These days this is done in
spi_register_driver(), so we can drop the manual assignment.

Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>
To: Solomon Peachy <pizza@shaftnet.org>
To: Kalle Valo <kvalo@codeaurora.org>
To: linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/wireless/cw1200/cw1200_spi.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/cw1200/cw1200_spi.c b/drivers/net/wireless/cw1200/cw1200_spi.c
index 7603546..29185ae 100644
--- a/drivers/net/wireless/cw1200/cw1200_spi.c
+++ b/drivers/net/wireless/cw1200/cw1200_spi.c
@@ -467,7 +467,6 @@ static struct spi_driver spi_driver = {
 	.remove		= cw1200_spi_disconnect,
 	.driver = {
 		.name		= "cw1200_wlan_spi",
-		.bus            = &spi_bus_type,
 		.owner          = THIS_MODULE,
 #ifdef CONFIG_PM
 		.pm		= &cw1200_pm_ops,
-- 
2.4.4

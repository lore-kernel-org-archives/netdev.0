From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH 2/2] net/fec: fix unterminated platform_device_id table
Date: Wed, 23 Feb 2011 17:28:46 +0800
Message-ID: <1298453326.25444.3.camel@mola>
References: <1298453244.25444.1.camel@mola>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298453244.25444.1.camel@mola>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The platform_device_id table is supposed to be zero-terminated.

Signed-off-by: Axel Lin <axel.lin@gmail.com>
---
 drivers/net/fec.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 74798be..f8a81ec 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -74,7 +74,8 @@ static struct platform_device_id fec_devtype[] = {
 	}, {
 		.name = "imx28-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME,
-	}
+	},
+	{ }
 };
 
 static unsigned char macaddr[ETH_ALEN];
-- 
1.7.2

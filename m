From: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Subject: [PATCH] can: make function can_get_bittiming static
Date: Thu, 21 Jul 2011 23:22:31 -0300
Message-ID: <1311301351-5298-1-git-send-email-cascardo@holoscopio.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	srcvale@holoscopio.com,
	Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function can_get_bittiming is not used anywhere else, so it should be
static.

Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
---
 drivers/net/can/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index d0f8c7e..9bf1116 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -208,7 +208,7 @@ static int can_fixup_bittiming(struct net_device *dev, struct can_bittiming *bt)
 	return 0;
 }
 
-int can_get_bittiming(struct net_device *dev, struct can_bittiming *bt)
+static int can_get_bittiming(struct net_device *dev, struct can_bittiming *bt)
 {
 	struct can_priv *priv = netdev_priv(dev);
 	int err;
-- 
1.7.5.4

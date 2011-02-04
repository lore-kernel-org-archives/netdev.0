From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH 12/20] net: can: at91_can: world-writable sysfs files
Date: Fri,  4 Feb 2011 15:23:50 +0300
Message-ID: <a6800dc8b0daed78256f98f52844cbbb48f4a76d.1296818921.git.segoon@openwall.com>
References: <cover.1296818921.git.segoon@openwall.com>
Cc: security@kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1296818921.git.segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't allow everybody to write to mb0_id file.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Cannot compile the driver, so it is not tested at all.

 drivers/net/can/at91_can.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 2532b96..57d2ffb 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1109,7 +1109,7 @@ static ssize_t at91_sysfs_set_mb0_id(struct device *dev,
 	return ret;
 }
 
-static DEVICE_ATTR(mb0_id, S_IWUGO | S_IRUGO,
+static DEVICE_ATTR(mb0_id, S_IWUSR | S_IRUGO,
 	at91_sysfs_show_mb0_id, at91_sysfs_set_mb0_id);
 
 static struct attribute *at91_sysfs_attrs[] = {
-- 
1.7.0.4

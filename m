From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 12/21] uwb: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 21:14:56 -0700
Message-ID: <2b17c8139285b5da29d7a70b6d08318272e2d168.1350618011.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/uwb/address.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/uwb/address.c b/drivers/uwb/address.c
index 8739c4f..ba4e4cf 100644
--- a/drivers/uwb/address.c
+++ b/drivers/uwb/address.c
@@ -343,7 +343,7 @@ static ssize_t uwb_rc_mac_addr_store(struct device *dev,
 		result = -EINVAL;
 		goto out;
 	}
-	if (is_multicast_ether_addr(addr.data)) {
+	if (eth_addr_multicast(addr.data)) {
 		dev_err(&rc->uwb_dev.dev, "refusing to set multicast "
 			"MAC address %s\n", buf);
 		result = -EINVAL;
-- 
1.7.8.111.gad25c.dirty

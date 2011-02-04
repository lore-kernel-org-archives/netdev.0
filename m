From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH 13/20] net: can: janz-ican3: world-writable sysfs termination file
Date: Fri,  4 Feb 2011 15:23:53 +0300
Message-ID: <6b49b9521416fbd50214485d3e14e5f254ada4f7.1296818921.git.segoon@openwall.com>
References: <cover.1296818921.git.segoon@openwall.com>
Cc: security@kernel.org, Wolfgang Grandegger <wg@grandegger.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1296818921.git.segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't allow everybody to set terminator via sysfs.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 Compile tested only.

 drivers/net/can/janz-ican3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index b9a6d7a..366f5cc 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1618,7 +1618,7 @@ static ssize_t ican3_sysfs_set_term(struct device *dev,
 	return count;
 }
 
-static DEVICE_ATTR(termination, S_IWUGO | S_IRUGO, ican3_sysfs_show_term,
+static DEVICE_ATTR(termination, S_IWUSR | S_IRUGO, ican3_sysfs_show_term,
 						   ican3_sysfs_set_term);
 
 static struct attribute *ican3_sysfs_attrs[] = {
-- 
1.7.0.4

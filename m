From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] Bluetooth: make device_type const
Date: Sat, 19 Aug 2017 14:54:47 +0530
Message-ID: <1503134687-12193-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com, davem@davemloft.net,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are only stored in the type field of a device
structure, which is const.
Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 net/bluetooth/hci_sysfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index ca7a35e..aa300f3 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -13,7 +13,7 @@ static void bt_link_release(struct device *dev)
 	kfree(conn);
 }
 
-static struct device_type bt_link = {
+static const struct device_type bt_link = {
 	.name    = "link",
 	.release = bt_link_release,
 };
@@ -86,7 +86,7 @@ static void bt_host_release(struct device *dev)
 	module_put(THIS_MODULE);
 }
 
-static struct device_type bt_host = {
+static const struct device_type bt_host = {
 	.name    = "host",
 	.release = bt_host_release,
 };
-- 
1.9.1

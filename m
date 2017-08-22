From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH] net: amd: constify zorro_device_id
Date: Tue, 22 Aug 2017 23:41:12 +0530
Message-ID: <1503425472-24469-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

zorro_device_id are not supposed to change at runtime. All functions
working with zorro_device_id provided by <linux/zorro.h> work with
const zorro_device_id. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/ethernet/amd/a2065.c   | 2 +-
 drivers/net/ethernet/amd/ariadne.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index ee4b94e..e22f976 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -643,7 +643,7 @@ static int a2065_init_one(struct zorro_dev *z,
 static void a2065_remove_one(struct zorro_dev *z);
 
 
-static struct zorro_device_id a2065_zorro_tbl[] = {
+static const struct zorro_device_id a2065_zorro_tbl[] = {
 	{ ZORRO_PROD_CBM_A2065_1 },
 	{ ZORRO_PROD_CBM_A2065_2 },
 	{ ZORRO_PROD_AMERISTAR_A2065 },
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index 5fd7b15..4b6a5cb 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -692,7 +692,7 @@ static void ariadne_remove_one(struct zorro_dev *z)
 	free_netdev(dev);
 }
 
-static struct zorro_device_id ariadne_zorro_tbl[] = {
+static const struct zorro_device_id ariadne_zorro_tbl[] = {
 	{ ZORRO_PROD_VILLAGE_TRONIC_ARIADNE },
 	{ 0 }
 };
-- 
2.7.4

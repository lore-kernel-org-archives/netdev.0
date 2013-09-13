From: Antonio Alecrim Jr <antonio.alecrim@gmail.com>
Subject: [PATCH 1/1] be2net: missing variable initialization
Date: Fri, 13 Sep 2013 14:05:49 -0300
Message-ID: <1379091949-4668-1-git-send-email-antonio.alecrim@gmail.com>
Cc: Antonio Alecrim Jr <antonio.alecrim@gmail.com>
To: Sathya Perla <sathya.perla@emulex.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Antonio Alecrim Jr <antonio.alecrim@gmail.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3224d28..100b528 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2802,7 +2802,7 @@ static int be_vfs_if_create(struct be_adapter *adapter)
 	struct be_resources res = {0};
 	struct be_vf_cfg *vf_cfg;
 	u32 cap_flags, en_flags, vf;
-	int status;
+	int status = 0;
 
 	cap_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
 		    BE_IF_FLAGS_MULTICAST;
-- 
1.8.3.1

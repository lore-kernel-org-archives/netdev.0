From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] be2net: fix sparse warning
Date: Thu,  5 Feb 2015 15:24:43 +0000
Message-ID: <1423149883-4717-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

be_cmds.c:2750:5: warning: symbol 'be_cmd_set_qos' was not declared. Should it be static?

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.8.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/emulex/benet/be_cmds.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 4bd425e..b5aa772 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2747,7 +2747,7 @@ err:
 	return status;
 }
 
-int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain)
+static int be_cmd_set_qos(struct be_adapter *adapter, u32 bps, u32 domain)
 {
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_set_qos *req;
-- 
1.9.1

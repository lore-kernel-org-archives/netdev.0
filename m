From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net caif: insert missing spaces in pr_* messages and unbreak multi-line strings
Date: Tue, 25 Oct 2016 12:18:42 +0100
Message-ID: <20161025111842.8110-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Some of the pr_* messages are missing spaces, so insert these and also
unbreak multi-line literal strings in pr_* messages

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/caif/cfcnfg.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index fa39fc2..273cb07 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -390,8 +390,7 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 	rcu_read_lock();
 
 	if (adapt_layer == NULL) {
-		pr_debug("link setup response but no client exist,"
-				"send linkdown back\n");
+		pr_debug("link setup response but no client exist, send linkdown back\n");
 		cfctrl_linkdown_req(cnfg->ctrl, channel_id, NULL);
 		goto unlock;
 	}
@@ -401,8 +400,7 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 
 	phyinfo = cfcnfg_get_phyinfo_rcu(cnfg, phyid);
 	if (phyinfo == NULL) {
-		pr_err("ERROR: Link Layer Device disappeared"
-				"while connecting\n");
+		pr_err("ERROR: Link Layer Device disappeared while connecting\n");
 		goto unlock;
 	}
 
@@ -436,8 +434,7 @@ cfcnfg_linkup_rsp(struct cflayer *layer, u8 channel_id, enum cfctrl_srv serv,
 		servicel = cfdbgl_create(channel_id, &phyinfo->dev_info);
 		break;
 	default:
-		pr_err("Protocol error. Link setup response "
-				"- unknown channel type\n");
+		pr_err("Protocol error. Link setup response - unknown channel type\n");
 		goto unlock;
 	}
 	if (!servicel)
-- 
2.9.3

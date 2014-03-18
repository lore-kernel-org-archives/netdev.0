From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH 7/9] rcu: Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)
Date: Wed, 19 Mar 2014 04:19:14 +0530
Message-ID: <58ab73ae9aaa60d9676d5e7cf3a331ae8536b4d2.1395182132.git.monamagarwal123@gmail.com>
References: <b7edeb452fff10b575a1a789d85ed1d23d84b061.1395182132.git.monamagarwal123@gmail.com>
Cc: linux-kernel@vger.kernel.org, eddie.wai@broadcom.com,
	paulmck@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b7edeb452fff10b575a1a789d85ed1d23d84b061.1395182132.git.monamagarwal123@gmail.com>
In-Reply-To: <cover.1395182132.git.monamagarwal123@gmail.com>
References: <cover.1395182132.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 drivers/target/tcm_fc/tfc_sess.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/target/tcm_fc/tfc_sess.c b/drivers/target/tcm_fc/tfc_sess.c
index 3269213..95fb826 100644
--- a/drivers/target/tcm_fc/tfc_sess.c
+++ b/drivers/target/tcm_fc/tfc_sess.c
@@ -110,7 +110,7 @@ static void ft_tport_delete(struct ft_tport *tport)
 	ft_sess_delete_all(tport);
 	lport = tport->lport;
 	BUG_ON(tport != lport->prov[FC_TYPE_FCP]);
-	rcu_assign_pointer(lport->prov[FC_TYPE_FCP], NULL);
+	RCU_INIT_POINTER(lport->prov[FC_TYPE_FCP], NULL);
 
 	tpg = tport->tpg;
 	if (tpg) {
-- 
1.7.9.5

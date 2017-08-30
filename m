From: Colin King <colin.king@canonical.com>
Subject: [PATCH][next] qed: fix spelling mistake: "calescing" -> "coalescing"
Date: Wed, 30 Aug 2017 12:40:12 +0100
Message-ID: <20170830114012.28260-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in DP_NOTICE message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 9a1645852015..085338990f49 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -2805,7 +2805,7 @@ static int qed_get_coalesce(struct qed_dev *cdev, u16 *coal, void *handle)
 	p_hwfn = p_cid->p_owner;
 	rc = qed_get_queue_coalesce(p_hwfn, coal, handle);
 	if (rc)
-		DP_NOTICE(p_hwfn, "Unable to read queue calescing\n");
+		DP_NOTICE(p_hwfn, "Unable to read queue coalescing\n");
 
 	return rc;
 }
-- 
2.14.1

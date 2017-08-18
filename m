From: Colin King <colin.king@canonical.com>
Subject: [PATCH][netdev-next] bnxt_en: fix spelling mistake: "swtichdev" -> "switchdev"
Date: Fri, 18 Aug 2017 16:40:00 +0100
Message-ID: <20170818154000.19068-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in a netdev_info message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index b05c5d0ee3f9..86cce6f53f78 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -428,7 +428,7 @@ static int bnxt_dl_eswitch_mode_set(struct devlink *devlink, u16 mode)
 	case DEVLINK_ESWITCH_MODE_SWITCHDEV:
 		if (pci_num_vf(bp->pdev) == 0) {
 			netdev_info(bp->dev,
-				    "Enable VFs before setting swtichdev mode");
+				    "Enable VFs before setting switchdev mode");
 			rc = -EPERM;
 			goto done;
 		}
-- 
2.11.0

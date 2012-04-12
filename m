From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH net-next] net: vxge: Add MODULE_FIRMWARE
Date: Thu, 12 Apr 2012 14:34:42 -0600
Message-ID: <1334262882-96973-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	Jon Mason <jdmason@kudzu.us>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: Jon Mason <jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 51387c3..dcef72d 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -4856,3 +4856,5 @@ vxge_closer(void)
 }
 module_init(vxge_starter);
 module_exit(vxge_closer);
+MODULE_FIRMWARE("vxge/X3fw-pxe.ncf");
+MODULE_FIRMWARE("vxge/X3fw.ncf");
-- 
1.7.9.5

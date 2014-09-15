From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 1/2] scsi_netlink : Make SCSI_NETLINK dependent on NET instead of selecting NET
Date: Mon, 15 Sep 2014 13:45:20 -0700
Message-ID: <1410813921-24400-2-git-send-email-anish@chelsio.com>
References: <1410813921-24400-1-git-send-email-anish@chelsio.com>
Cc: linux-scsi@vger.kernel.org, davem@davemloft.net,
	JBottomley@parallels.com, mchan@broadcom.com,
	eddie.wai@broadcom.com, rdunlap@infradead.org, jim.epost@gmail.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1410813921-24400-1-git-send-email-anish@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Required for avoiding recursive dependencies in the Kconfig, brought out
by fixing randconfig error for bnx2i/bnx2fc in the patch that follows.
As suggested by Randy Dunlap

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/Kconfig b/drivers/scsi/Kconfig
index 18a3358..756cdda 100644
--- a/drivers/scsi/Kconfig
+++ b/drivers/scsi/Kconfig
@@ -43,7 +43,7 @@ config SCSI_DMA
 config SCSI_NETLINK
 	bool
 	default	n
-	select NET
+	depends on NET
 
 config SCSI_PROC_FS
 	bool "legacy /proc/scsi/ support"
-- 
2.1.0


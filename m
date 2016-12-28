From: Colin King <colin.king@canonical.com>
Subject: [PATCH] drivers: atm: eni: rename macro DAUGTHER_ID to fix spelling mistake
Date: Wed, 28 Dec 2016 17:31:20 +0000
Message-ID: <20161228173120.20207-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Chas Williams <3chas3@gmail.com>,
        linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Rename DAUGTHER_ID to DAUGHTER_ID to fix spelling mistake

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/atm/eni.c    | 2 +-
 drivers/atm/midway.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 40c2d56..13fe61a 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1779,7 +1779,7 @@ static int eni_do_init(struct atm_dev *dev)
 	printk(")\n");
 	printk(KERN_NOTICE DEV_LABEL "(itf %d): %s,%s\n",dev->number,
 	    eni_in(MID_RES_ID_MCON) & 0x200 ? "ASIC" : "FPGA",
-	    media_name[eni_in(MID_RES_ID_MCON) & DAUGTHER_ID]);
+	    media_name[eni_in(MID_RES_ID_MCON) & DAUGHTER_ID]);
 
 	error = suni_init(dev);
 	if (error)
diff --git a/drivers/atm/midway.h b/drivers/atm/midway.h
index 432525a..d8bec0f 100644
--- a/drivers/atm/midway.h
+++ b/drivers/atm/midway.h
@@ -56,7 +56,7 @@
 #define MID_CON_SUNI	0x00000040	/* 0: UTOPIA; 1: SUNI */
 #define MID_CON_V6	0x00000020	/* 0: non-pipel UTOPIA (required iff
 					   !CON_SUNI; 1: UTOPIA */
-#define DAUGTHER_ID	0x0000001f	/* daugther board id */
+#define DAUGHTER_ID	0x0000001f	/* daughter board id */
 
 /*
  * Interrupt Status Acknowledge, Interrupt Status & Interrupt Enable
-- 
2.10.2

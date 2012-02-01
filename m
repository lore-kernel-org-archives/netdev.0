From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] atm: Fix typo in lanai.c
Date: Wed,  1 Feb 2012 22:05:13 +0900
Message-ID: <1328101513-1704-1-git-send-email-standby24x7@gmail.com>
Cc: linux-kernel@vger.kernel.org, trivial@kernel.org,
	standby24x7@gmail.com
To: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling "reseting" to resetting" in
drivers/atm/lanai.c

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/atm/lanai.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index f556969..68c7588 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -1572,7 +1572,7 @@ static inline void host_vcc_unbind(struct lanai_dev *lanai,
 
 static void lanai_reset(struct lanai_dev *lanai)
 {
-	printk(KERN_CRIT DEV_LABEL "(itf %d): *NOT* reseting - not "
+	printk(KERN_CRIT DEV_LABEL "(itf %d): *NOT* resetting - not "
 	    "implemented\n", lanai->number);
 	/* TODO */
 	/* The following is just a hack until we write the real
-- 
1.7.6.5

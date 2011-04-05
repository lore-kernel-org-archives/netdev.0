From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH 12/34] isdn/diva: Drop __TIME__ usage
Date: Tue,  5 Apr 2011 16:58:59 +0200
Message-ID: <1302015561-21047-13-git-send-email-mmarek@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Cc: linux-kernel@vger.kernel.org, Armin Schindler <mac@melware.de>,
	netdev@vger.kernel.org
To: linux-kbuild@vger.kernel.org
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel already prints its build timestamp during boot, no need to
repeat it in random drivers and produce different object files each
time.

Cc: Armin Schindler <mac@melware.de>
Cc: netdev@vger.kernel.org
Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 drivers/isdn/hardware/eicon/divasfunc.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/divasfunc.c b/drivers/isdn/hardware/eicon/divasfunc.c
index d36a4c0..0bbee78 100644
--- a/drivers/isdn/hardware/eicon/divasfunc.c
+++ b/drivers/isdn/hardware/eicon/divasfunc.c
@@ -113,9 +113,8 @@ void diva_xdi_didd_remove_adapter(int card)
 static void start_dbg(void)
 {
 	DbgRegister("DIVAS", DRIVERRELEASE_DIVAS, (debugmask) ? debugmask : DBG_DEFAULT);
-	DBG_LOG(("DIVA ISDNXDI BUILD (%s[%s]-%s-%s)",
-		 DIVA_BUILD, diva_xdi_common_code_build, __DATE__,
-		 __TIME__))
+	DBG_LOG(("DIVA ISDNXDI BUILD (%s[%s])",
+		 DIVA_BUILD, diva_xdi_common_code_build))
 }
 
 /*
-- 
1.7.4.1


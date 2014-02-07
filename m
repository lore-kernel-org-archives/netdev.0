From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 11/12] staging: r8188eu: Remove ODM_SetTimer
Date: Thu,  6 Feb 2014 20:45:46 -0600
Message-ID: <1391741147-3047-12-git-send-email-Larry.Finger@lwfinger.net>
References: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1391741147-3047-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This wrapper is not used.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 5 -----
 drivers/staging/rtl8188eu/include/odm_interface.h | 2 --
 2 files changed, 7 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index f6e8c1c..92dadc1 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -20,11 +20,6 @@
 
 #include "odm_precomp.h"
 
-void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer, u32 msDelay)
-{
-	_set_timer(pTimer, msDelay); /* ms */
-}
-
 void ODM_InitializeTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer,
 			 void *CallBackFunc, void *pContext,
 			 const char *szID)
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 35de915..6ecd296 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -80,8 +80,6 @@ typedef void (*RT_WORKITEM_CALL_BACK)(void *pContext);
 /*  Memory Relative Function. */
 
 /*  ODM Timer relative API. */
-void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer,
-		  u32 msDelay);
 
 void ODM_InitializeTimer(struct odm_dm_struct *pDM_Odm,
 			 struct timer_list *pTimer, void *CallBackFunc,
-- 
1.8.4.5

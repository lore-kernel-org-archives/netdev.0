From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 02/12] staging: r8188eu: Remove ODM_Read2Byte
Date: Thu,  6 Feb 2014 20:45:37 -0600
Message-ID: <1391741147-3047-3-git-send-email-Larry.Finger@lwfinger.net>
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

This routine is never used.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 6 ------
 drivers/staging/rtl8188eu/include/odm_interface.h | 2 --
 2 files changed, 8 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index 5b29067..f8d1692 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -21,12 +21,6 @@
 #include "odm_precomp.h"
 /*  ODM IO Relative API. */
 
-u16 ODM_Read2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr)
-{
-	struct adapter *Adapter = pDM_Odm->Adapter;
-	return rtw_read16(Adapter, RegAddr);
-}
-
 u32 ODM_Read4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr)
 {
 	struct adapter *Adapter = pDM_Odm->Adapter;
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index ba06101..84c6449 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -77,8 +77,6 @@ typedef void (*RT_WORKITEM_CALL_BACK)(void *pContext);
 
 /*  =========== EXtern Function Prototype */
 
-u16 ODM_Read2Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr);
-
 u32 ODM_Read4Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr);
 
 void ODM_Write1Byte(struct odm_dm_struct *pDM_Odm, u32 RegAddr, u8 Data);
-- 
1.8.4.5

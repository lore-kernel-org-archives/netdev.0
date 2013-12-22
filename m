From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 18/31] staging: r8188eu: Remove - number of dummy and unused routines
Date: Sun, 22 Dec 2013 17:36:49 -0600
Message-ID: <1387755422-11443-19-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:48176 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756807Ab3LVXiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:38:21 -0500
Received: by mail-pd0-f173.google.com with SMTP id p10so4540948pdj.4
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:38:21 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These routines include:
ODM_StartWorkItem()
ODM_StopWorkItem()
ODM_FreeWorkItem()
ODM_ScheduleWorkItem()
ODM_IsWorkItemScheduled()

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/hal/odm_interface.c     | 20 --------------------
 drivers/staging/rtl8188eu/include/odm_interface.h | 10 ----------
 2 files changed, 30 deletions(-)

diff --git a/drivers/staging/rtl8188eu/hal/odm_interface.c b/drivers/staging/rtl8188eu/hal/odm_interface.c
index e6b3543..74d37cf 100644
--- a/drivers/staging/rtl8188eu/hal/odm_interface.c
+++ b/drivers/staging/rtl8188eu/hal/odm_interface.c
@@ -90,26 +90,6 @@ void ODM_InitializeWorkItem(struct odm_dm_struct *pDM_Odm, void *pRtWorkItem,
 {
 }
 
-void ODM_StartWorkItem(void *pRtWorkItem)
-{
-}
-
-void ODM_StopWorkItem(void *pRtWorkItem)
-{
-}
-
-void ODM_FreeWorkItem(void *pRtWorkItem)
-{
-}
-
-void ODM_ScheduleWorkItem(void *pRtWorkItem)
-{
-}
-
-void ODM_IsWorkItemScheduled(void *pRtWorkItem)
-{
-}
-
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer, u32 msDelay)
 {
 	_set_timer(pTimer, msDelay); /* ms */
diff --git a/drivers/staging/rtl8188eu/include/odm_interface.h b/drivers/staging/rtl8188eu/include/odm_interface.h
index 73110c8..f2e32a1 100644
--- a/drivers/staging/rtl8188eu/include/odm_interface.h
+++ b/drivers/staging/rtl8188eu/include/odm_interface.h
@@ -108,16 +108,6 @@ void ODM_InitializeWorkItem(struct odm_dm_struct *pDM_Odm, void *pRtWorkItem,
 			    RT_WORKITEM_CALL_BACK RtWorkItemCallback,
 			    void *pContext, const char *szID);
 
-void ODM_StartWorkItem(void *pRtWorkItem);
-
-void ODM_StopWorkItem(void *pRtWorkItem);
-
-void ODM_FreeWorkItem(void *pRtWorkItem);
-
-void ODM_ScheduleWorkItem(void *pRtWorkItem);
-
-void ODM_IsWorkItemScheduled(void *pRtWorkItem);
-
 /*  ODM Timer relative API. */
 void ODM_SetTimer(struct odm_dm_struct *pDM_Odm, struct timer_list *pTimer,
 		  u32 msDelay);
-- 
1.8.4

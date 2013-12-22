From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/31] staging: r8188eu: Remove unused atomic_xxx wrappers
Date: Sun, 22 Dec 2013 17:36:37 -0600
Message-ID: <1387755422-11443-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:59333 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756181Ab3LVXhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:37:37 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so4643819pbb.36
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 15:37:36 -0800 (PST)
In-Reply-To: <1387755422-11443-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8188eu/include/osdep_service.h |  7 -----
 drivers/staging/rtl8188eu/os_dep/osdep_service.c  | 35 -----------------------
 2 files changed, 42 deletions(-)

diff --git a/drivers/staging/rtl8188eu/include/osdep_service.h b/drivers/staging/rtl8188eu/include/osdep_service.h
index 7b2e87a..593d5a8 100644
--- a/drivers/staging/rtl8188eu/include/osdep_service.h
+++ b/drivers/staging/rtl8188eu/include/osdep_service.h
@@ -358,15 +358,8 @@ static inline u32 bitshift(u32 bitmask)
 #define PATH_LENGTH_MAX PATH_MAX
 
 /* Atomic integer operations */
-int ATOMIC_READ(atomic_t *v);
-void ATOMIC_ADD(atomic_t *v, int i);
-void ATOMIC_SUB(atomic_t *v, int i);
 void ATOMIC_INC(atomic_t *v);
-void ATOMIC_DEC(atomic_t *v);
-int ATOMIC_ADD_RETURN(atomic_t *v, int i);
-int ATOMIC_SUB_RETURN(atomic_t *v, int i);
 int ATOMIC_INC_RETURN(atomic_t *v);
-int ATOMIC_DEC_RETURN(atomic_t *v);
 
 struct rtw_netdev_priv_indicator {
 	void *priv;
diff --git a/drivers/staging/rtl8188eu/os_dep/osdep_service.c b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
index 360703d..b699fe0 100644
--- a/drivers/staging/rtl8188eu/os_dep/osdep_service.c
+++ b/drivers/staging/rtl8188eu/os_dep/osdep_service.c
@@ -247,51 +247,16 @@ void rtw_sleep_schedulable(int ms)
 
 #define RTW_SUSPEND_LOCK_NAME "rtw_wifi"
 
-inline int ATOMIC_READ(atomic_t *v)
-{
-	return atomic_read(v);
-}
-
-inline void ATOMIC_ADD(atomic_t *v, int i)
-{
-	atomic_add(i, v);
-}
-
-inline void ATOMIC_SUB(atomic_t *v, int i)
-{
-	atomic_sub(i, v);
-}
-
 inline void ATOMIC_INC(atomic_t *v)
 {
 	atomic_inc(v);
 }
 
-inline void ATOMIC_DEC(atomic_t *v)
-{
-	atomic_dec(v);
-}
-
-inline int ATOMIC_ADD_RETURN(atomic_t *v, int i)
-{
-	return atomic_add_return(i, v);
-}
-
-inline int ATOMIC_SUB_RETURN(atomic_t *v, int i)
-{
-	return atomic_sub_return(i, v);
-}
-
 inline int ATOMIC_INC_RETURN(atomic_t *v)
 {
 	return atomic_inc_return(v);
 }
 
-inline int ATOMIC_DEC_RETURN(atomic_t *v)
-{
-	return atomic_dec_return(v);
-}
-
 struct net_device *rtw_alloc_etherdev_with_old_priv(int sizeof_priv,
 						    void *old_priv)
 {
-- 
1.8.4

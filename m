From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/4 net-next] tg3: Remove IS_ENABLED(CONFIG_HWMON) check
Date: Sun, 6 Jan 2013 14:51:10 -0800
Message-ID: <1357512670-17636-4-git-send-email-mchan@broadcom.com>
References: <1357512670-17636-1-git-send-email-mchan@broadcom.com>
 <1357512670-17636-2-git-send-email-mchan@broadcom.com>
 <1357512670-17636-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1980 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166Ab3AFWfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2013 17:35:06 -0500
In-Reply-To: <1357512670-17636-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nithin Nayak Sujir <nsujir@broadcom.com>

Commit de0a41484c47d783dd4d442914815076aa2caac2 added Kconfig logic to
select HWMON and removed all the IS_ENABLED(CONFIG_HWMON) checks in the
tg3.c file. It missed this one check in the header.

Update version to 3.129 and update copyright year.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    6 +++---
 drivers/net/ethernet/broadcom/tg3.h |    4 +---
 2 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 3596b7b..bc4d989 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001, 2002, 2003 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2005-2012 Broadcom Corporation.
+ * Copyright (C) 2005-2013 Broadcom Corporation.
  *
  * Firmware is:
  *	Derived from proprietary unpublished source code,
@@ -93,10 +93,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			128
+#define TG3_MIN_NUM			129
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"December 03, 2012"
+#define DRV_MODULE_RELDATE	"January 06, 2013"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 39afc0e..9cd88a4 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -4,7 +4,7 @@
  * Copyright (C) 2001, 2002, 2003, 2004 David S. Miller (davem@redhat.com)
  * Copyright (C) 2001 Jeff Garzik (jgarzik@pobox.com)
  * Copyright (C) 2004 Sun Microsystems Inc.
- * Copyright (C) 2007-2012 Broadcom Corporation.
+ * Copyright (C) 2007-2013 Broadcom Corporation.
  */
 
 #ifndef _T3_H
@@ -3348,9 +3348,7 @@ struct tg3 {
 	const struct firmware		*fw;
 	u32				fw_len; /* includes BSS */
 
-#if IS_ENABLED(CONFIG_HWMON)
 	struct device			*hwmon_dev;
-#endif
 	bool				link_up;
 };
 
-- 
1.7.1

From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH 2/2] thermal: shorten too long mcast group name
Date: Tue, 19 Mar 2013 20:47:28 +0900
Message-ID: <1363693648-10015-3-git-send-email-yamato@redhat.com>
References: <1363693648-10015-1-git-send-email-yamato@redhat.com>
Cc: Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h219-110-095-248.catv01.itscom.jp ([219.110.95.248]:55726 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933158Ab3CSR2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:28:36 -0400
In-Reply-To: <1363693648-10015-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original name is too long.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 include/linux/thermal.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/thermal.h b/include/linux/thermal.h
index f0bd7f9..e3c0ae9 100644
--- a/include/linux/thermal.h
+++ b/include/linux/thermal.h
@@ -44,7 +44,7 @@
 /* Adding event notification support elements */
 #define THERMAL_GENL_FAMILY_NAME                "thermal_event"
 #define THERMAL_GENL_VERSION                    0x01
-#define THERMAL_GENL_MCAST_GROUP_NAME           "thermal_mc_group"
+#define THERMAL_GENL_MCAST_GROUP_NAME           "thermal_mc_grp"
 
 /* Default Thermal Governor */
 #if defined(CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE)
-- 
1.7.11.7

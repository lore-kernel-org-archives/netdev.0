From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Subject: [PATCH] Protect if_phonet.h against multiple inclusions.
Date: Wed,  1 Oct 2008 10:57:38 +0300
Message-ID: <1222847858-16706-1-git-send-email-remi.denis-courmont@nokia.com>
References: <200810011054.52951.remi.denis-courmont@nokia.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:65337 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbYJAH6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 03:58:30 -0400
In-Reply-To: <200810011054.52951.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 include/linux/if_phonet.h |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_phonet.h b/include/linux/if_phonet.h
index 7e98921..d70034b 100644
--- a/include/linux/if_phonet.h
+++ b/include/linux/if_phonet.h
@@ -5,14 +5,15 @@
  *
  * Copyright (C) 2008 Nokia Corporation. All rights reserved.
  */
+#ifndef LINUX_IF_PHONET_H
+#define LINUX_IF_PHONET_H
 
-#define PHONET_HEADER_LEN	8	/* Phonet header length */
-
-#define PHONET_MIN_MTU		6
-/* 6 bytes header + 65535 bytes payload */
-#define PHONET_MAX_MTU		65541
+#define PHONET_MIN_MTU		6	/* pn_length = 0 */
+#define PHONET_MAX_MTU		65541	/* pn_length = 0xffff */
 #define PHONET_DEV_MTU		PHONET_MAX_MTU
 
 #ifdef __KERNEL__
 extern struct header_ops phonet_header_ops;
 #endif
+
+#endif
-- 
1.5.4.3


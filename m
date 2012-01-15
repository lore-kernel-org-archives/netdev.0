From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/8] brcmfmac: Convert printk(KERN_DEBUG to pr_debug
Date: Sun, 15 Jan 2012 00:38:39 -0800
Message-ID: <836088dbbb4916e162ac212d05a5e77a9ba451a1.1326616556.git.joe@perches.com>
References: <cover.1326616556.git.joe@perches.com>
Cc: Brett Rudley <brudley@broadcom.com>,
	Henry Ptasinski <henryp@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Kan Yan <kanyan@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:35879 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751285Ab2AOIjb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jan 2012 03:39:31 -0500
In-Reply-To: <cover.1326616556.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow dynamic debugging.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h b/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
index 8b2060b..f5ca9fc 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
@@ -39,13 +39,13 @@ do {									\
 	if (BRCMF_ERROR_VAL == BRCMF_##level##_VAL) {			\
 		if (brcmf_msg_level & BRCMF_##level##_VAL) {		\
 			if (net_ratelimit())				\
-				printk(KERN_DEBUG "%s: " fmt,		\
-				       __func__, ##__VA_ARGS__);	\
+				pr_debug("%s: " fmt,			\
+					 __func__, ##__VA_ARGS__);	\
 		}							\
 	} else {							\
 		if (brcmf_msg_level & BRCMF_##level##_VAL) {		\
-			printk(KERN_DEBUG "%s: " fmt,			\
-			       __func__, ##__VA_ARGS__);		\
+			pr_debug("%s: " fmt,				\
+				 __func__, ##__VA_ARGS__);		\
 		}							\
 	}								\
 } while (0)
-- 
1.7.8.111.gad25c.dirty

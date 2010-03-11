From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH] ip: correctly report tunnel link type
Date: Thu, 11 Mar 2010 21:22:31 +0100
Message-ID: <1268338952-6832-1-git-send-email-jengelh@medozas.de>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:39176 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754606Ab0CKUWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 15:22:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Up until now, "tun" tunnels were displayed as link/[65534].

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 lib/ll_types.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/ll_types.c b/lib/ll_types.c
index 9d75bd2..846cdb0 100644
--- a/lib/ll_types.c
+++ b/lib/ll_types.c
@@ -125,6 +125,9 @@ __PF(IEEE80211_PRISM,ieee802.11/prism)
 #ifdef ARPHRD_IEEE80211_RADIOTAP
 __PF(IEEE80211_RADIOTAP,ieee802.11/radiotap)
 #endif
+#ifdef ARPHRD_NONE
+__PF(NONE, none)
+#endif
 #ifdef ARPHRD_VOID
 __PF(VOID,void)
 #endif
-- 
1.7.0


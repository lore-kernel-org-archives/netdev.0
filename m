From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH] ip: correctly report 802.15.4 link type
Date: Sun, 25 Jul 2010 22:28:02 +0200
Message-ID: <1280089683-12020-2-git-send-email-jengelh@medozas.de>
References: <1280089683-12020-1-git-send-email-jengelh@medozas.de>
Cc: netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:39489 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585Ab0GYU2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jul 2010 16:28:08 -0400
In-Reply-To: <1280089683-12020-1-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Up until now, the "hardwpan" devices were displayed as link/[804].

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 lib/ll_types.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/ll_types.c b/lib/ll_types.c
index 846cdb0..1cc46b6 100644
--- a/lib/ll_types.c
+++ b/lib/ll_types.c
@@ -125,6 +125,9 @@ __PF(IEEE80211_PRISM,ieee802.11/prism)
 #ifdef ARPHRD_IEEE80211_RADIOTAP
 __PF(IEEE80211_RADIOTAP,ieee802.11/radiotap)
 #endif
+#ifdef ARPHRD_IEEE802154
+__PF(IEEE802154, ieee802.15.4)
+#endif
 #ifdef ARPHRD_NONE
 __PF(NONE, none)
 #endif
-- 
1.7.1


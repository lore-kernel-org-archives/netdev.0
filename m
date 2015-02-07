From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 2/2] drivers: isdn: icn: icn.h Clean up trivial checkpatch errors.
Date: Sat,  7 Feb 2015 17:12:43 +0100
Message-ID: <1423325563-11412-3-git-send-email-baspeters93@gmail.com>
References: <1423325563-11412-1-git-send-email-baspeters93@gmail.com>
Cc: dan.carpenter@oracle.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38140 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757848AbbBGQMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 11:12:53 -0500
In-Reply-To: <1423325563-11412-1-git-send-email-baspeters93@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bas Peters <baspeters93@gmail.com>
---
 drivers/isdn/icn/icn.h | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/icn/icn.h b/drivers/isdn/icn/icn.h
index b713466..05daed2 100644
--- a/drivers/isdn/icn/icn.h
+++ b/drivers/isdn/icn/icn.h
@@ -54,7 +54,7 @@ typedef struct icn_cdef {
 
 /* some useful macros for debugging */
 #ifdef ICN_DEBUG_PORT
-#define OUTB_P(v, p) {printk(KERN_DEBUG "icn: outb_p(0x%02x,0x%03x)\n", v, p); outb_p(v, p);}
+#define OUTB_P(v, p) {printk(KERN_DEBUG "icn: outb_p(0x%02x,0x%03x)\n", v, p); outb_p(v, p); }
 #else
 #define OUTB_P outb
 #endif
@@ -186,8 +186,7 @@ typedef icn_dev *icn_devptr;
 #ifdef __KERNEL__
 
 static icn_card *cards = (icn_card *) 0;
-static u_char chan2bank[] =
-{0, 4, 8, 12};                  /* for icn_map_channel() */
+static u_char chan2bank[] = {0, 4, 8, 12}; /* for icn_map_channel() */
 
 static icn_dev dev;
 
-- 
2.1.0

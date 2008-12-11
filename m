From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 4/9][v2] mISDN: un-export symbol 'plx_lock'
Date: Thu, 11 Dec 2008 22:36:00 +0100
Message-ID: <49419a2d.06a1660a.5c0a.ffff908c@mx.google.com>
Cc: Karsten Keil <kkeil@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:31985 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757886AbYLKWyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 17:54:41 -0500
Received: by mu-out-0910.google.com with SMTP id g7so720797muf.1
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 14:54:38 -0800 (PST)
Cc: linux-kernel@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'plx_lock' is only used within hfcmulti.c.

Fix this warning:

  drivers/isdn/hardware/mISDN/hfcmulti.c:176:1: warning: symbol 'plx_lock' shadows an earlier one
  drivers/isdn/hardware/mISDN/hfcmulti.c:175:19: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
Acked-by: Karsten Keil <kkeil@suse.de>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 599d832..970201d 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -173,7 +173,6 @@ static int interrupt_registered;
 static struct hfc_multi *syncmaster;
 static int plxsd_master; /* if we have a master card (yet) */
 static spinlock_t plx_lock; /* may not acquire other lock inside */
-EXPORT_SYMBOL(plx_lock);
 
 #define	TYP_E1		1
 #define	TYP_4S		4
-- 
1.5.6.3


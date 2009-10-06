From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/4] isdn: make capidrv module parameter "debugmode" writeable
Date: Wed,  7 Oct 2009 00:18:15 +0200 (CEST)
Message-ID: <20091006-patch-capi-4.tilman@imap.cc>
References: <20091006-patch-capi-0.tilman@imap.cc>
Cc: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933563AbZJFWTI@vger.kernel.org>
In-Reply-To: <20091006-patch-capi-0.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Being able to change the debugmode module parameter of capidrv on the
fly is quite useful for debugging and doesn't do any harm.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capidrv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 4921eae..3e6d17f 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -40,7 +40,7 @@ static int debugmode = 0;
 MODULE_DESCRIPTION("CAPI4Linux: Interface to ISDN4Linux");
 MODULE_AUTHOR("Carsten Paeth");
 MODULE_LICENSE("GPL");
-module_param(debugmode, uint, 0);
+module_param(debugmode, uint, S_IRUGO|S_IWUSR);
 
 /* -------- type definitions ----------------------------------------- */
 
-- 
1.6.2.1.214.ge986c

From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 4/4] isdn: make capidrv module parameter "debugmode" writeable
Date: Sun,  6 Sep 2009 20:58:52 +0200 (CEST)
Message-ID: <20090906-patch-capi-4.tilman@imap.cc>
References: <20090906-patch-capi-0.tilman@imap.cc>
Cc: Carsten Paeth <calle@calle.de>
To: davem@davemloft.net, Karsten Keil <keil@b1-systems.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	i4ldeveloper@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758198AbZIFS70@vger.kernel.org>
In-Reply-To: <20090906-patch-capi-0.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Being able to change the debugmode module parameter of capidrv on the
fly is quite useful for debugging and doesn't do any harm.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capidrv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index c3f5472..75c691c 100644
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

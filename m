From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 5/5] ISDN-Gigaset: Enclose two expressions for the sizeof
 operator by parentheses
Date: Mon, 26 Sep 2016 17:44:39 +0200
Message-ID: <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:51124 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934308AbcIZPpL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 11:45:11 -0400
In-Reply-To: <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 26 Sep 2016 17:03:56 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script "checkpatch.pl" can point information out like the following.

WARNING: sizeof … should be sizeof(…)

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/gigaset/common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 2e9382f..d901ed7 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 {
 	unsigned char outbuf[80];
 	unsigned char c;
-	size_t space = sizeof outbuf - 1;
+	size_t space = sizeof(outbuf - 1);
 	unsigned char *out = outbuf;
 	size_t numin = len;
 
@@ -1079,7 +1079,7 @@ struct gigaset_driver *gigaset_initdriver(unsigned minor, unsigned minors,
 	unsigned long flags;
 	unsigned i;
 
-	drv = kmalloc(sizeof *drv, GFP_KERNEL);
+	drv = kmalloc(sizeof(*drv), GFP_KERNEL);
 	if (!drv)
 		return NULL;
 
-- 
2.10.0

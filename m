From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/5] ISDN-Gigaset: Delete an error message for a failed memory
 allocation
Date: Mon, 26 Sep 2016 17:42:11 +0200
Message-ID: <64f7ba12-1b0e-9fac-9b2e-d22e7fb3fcc7@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Wolfram Sang <wsa@the-dreams.de>
To: gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 26 Sep 2016 15:35:47 +0200

Omit an extra message for a memory allocation failure in this function.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/isdn/gigaset/common.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index f505b42..c05a2a4 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -712,7 +712,6 @@ struct cardstate *gigaset_initcs(struct gigaset_driver *drv, int channels,
 	cs->bcs = kmalloc_array(channels, sizeof(*cs->bcs), GFP_KERNEL);
 	cs->inbuf = kmalloc(sizeof(*cs->inbuf), GFP_KERNEL);
 	if (!cs->bcs || !cs->inbuf) {
-		pr_err("out of memory\n");
 		goto error;
 	}
 	++cs->cs_init;
-- 
2.10.0


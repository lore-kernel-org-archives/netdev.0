From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v2 5/5] ISDN-Gigaset: Enclose two expressions for the sizeof
 operator by parentheses
Date: Mon, 26 Sep 2016 19:44:56 +0200
Message-ID: <f9dd122f-b0ed-0398-2a13-4d31693356fa@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <6d4bbb77-914f-19b8-a1a9-2731d1158612@users.sourceforge.net>
 <e97b38b6-8c02-6733-8b57-9786bfb911a6@users.sourceforge.net>
 <063D6719AE5E284EB5DD2968C1650D6DB0109E63@AcuExch.aculab.com>
 <1474907003.2238.13.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>,
        David Laight <David.Laight@ACULAB.COM>,
        "gigaset307x-common@lists.sourceforge.net"
        <gigaset307x-common@lists.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474907003.2238.13.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 26 Sep 2016 19:34:27 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script "checkpatch.pl" can point information out like the following.

WARNING: sizeof … should be sizeof(…)

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---

v2: Position the desired closing parenthesis behind the variable name for
    a character buffer.

 drivers/isdn/gigaset/common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 2e9382f..dba44e1 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -53,7 +53,7 @@ void gigaset_dbg_buffer(enum debuglevel level, const unsigned char *msg,
 {
 	unsigned char outbuf[80];
 	unsigned char c;
-	size_t space = sizeof outbuf - 1;
+	size_t space = sizeof(outbuf) - 1;
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

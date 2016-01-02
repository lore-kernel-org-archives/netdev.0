From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 4/5] xen-netback: Replace a variable initialisation by an
 assignment in xen_register_watchers()
Date: Sat, 2 Jan 2016 18:58:09 +0100
Message-ID: <56880FB1.1030802@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56880DD4.2090806@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56880DD4.2090806@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 2 Jan 2016 18:23:16 +0100

Replace an explicit initialisation for one local variable at the beginning
by an assignment.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/xen-netback/xenbus.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index aff963f..e8dfc3d 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -687,11 +687,12 @@ static int xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
 {
 	int err = 0;
 	char *node;
-	unsigned maxlen = strlen(dev->nodename) + sizeof("/rate");
+	unsigned maxlen;
 
 	if (vif->credit_watch.node)
 		return -EADDRINUSE;
 
+	maxlen = strlen(dev->nodename) + sizeof("/rate");
 	node = kmalloc(maxlen, GFP_KERNEL);
 	if (!node)
 		return -ENOMEM;
-- 
2.6.3

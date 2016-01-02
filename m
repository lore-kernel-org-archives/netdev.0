From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 1/5] xen-netback: Delete an unnecessary assignment in
 connect_rings()
Date: Sat, 2 Jan 2016 18:54:40 +0100
Message-ID: <56880EE0.6080405@users.sourceforge.net>
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
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <56880DD4.2090806@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 2 Jan 2016 17:32:40 +0100

Remove the assignment for a local variable because its value is not
changed compared to the one from a previous function call.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/xen-netback/xenbus.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 56ebd82..7f2895d 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -941,7 +941,6 @@ static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
 		goto err;
 	}
 
-	err = 0;
 err: /* Regular return falls through with err == 0 */
 	kfree(xspath);
 	return err;
-- 
2.6.3


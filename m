From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] [sparse] irlmp warnings.
Date: Tue, 13 Jul 2004 10:09:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040713100956.66ff796f@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of sparse warnings about 0 vs NULL. in irlmp.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/irda/irlmp.c b/net/irda/irlmp.c
--- a/net/irda/irlmp.c	2004-07-13 10:05:18 -07:00
+++ b/net/irda/irlmp.c	2004-07-13 10:05:18 -07:00
@@ -1491,7 +1491,7 @@
 	service = kmalloc(sizeof(irlmp_service_t), GFP_ATOMIC);
 	if (!service) {
 		IRDA_DEBUG(1, "%s(), Unable to kmalloc!\n", __FUNCTION__);
-		return 0;
+		return NULL;
 	}
 	service->hints.word = hints;
 	hashbin_insert(irlmp->services, (irda_queue_t *) service,
@@ -1561,13 +1561,13 @@
 	irlmp_client_t *client;
 
 	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
-	ASSERT(irlmp != NULL, return 0;);
+	ASSERT(irlmp != NULL, return NULL;);
 
 	/* Make a new registration */
 	client = kmalloc(sizeof(irlmp_client_t), GFP_ATOMIC);
 	if (!client) {
 		IRDA_DEBUG( 1, "%s(), Unable to kmalloc!\n", __FUNCTION__);
-		return 0;
+		return NULL;
 	}
 
 	/* Register the details */

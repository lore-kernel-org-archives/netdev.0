From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 7/7] [IrDA] Misc spelling corrections.
Date: Thu, 19 Apr 2007 00:32:09 +0300
Message-ID: <20070418214752.135291365@sortiz.org>
References: <20070418213202.214829666@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "G. Liakhovetski" <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline;
	filename=0008-IrDA-net-2.6.22-Misc-spelling-corrections.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Guennadi Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>

Spelling corrections, from "to" to "too".

Signed-off-by: G. Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/irlap_event.c |    2 +-
 net/irda/irlap_frame.c |   14 +++++++-------
 net/irda/irttp.c       |    4 ++--
 net/irda/parameters.c  |    8 ++++----
 4 files changed, 14 insertions(+), 14 deletions(-)

Index: net-2.6.22-quilt/net/irda/irlap_event.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/irlap_event.c	2007-04-18 01:57:48.000000000 +0300
+++ net-2.6.22-quilt/net/irda/irlap_event.c	2007-04-18 02:16:44.000000000 +0300
@@ -590,7 +590,7 @@
 		if (!self->discovery_log) {
 			IRDA_WARNING("%s: discovery log is gone! "
 				     "maybe the discovery timeout has been set"
-				     " to short?\n", __FUNCTION__);
+				     " too short?\n", __FUNCTION__);
 			break;
 		}
 		hashbin_insert(self->discovery_log,
Index: net-2.6.22-quilt/net/irda/irlap_frame.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/irlap_frame.c	2007-04-18 02:16:43.000000000 +0300
+++ net-2.6.22-quilt/net/irda/irlap_frame.c	2007-04-18 02:16:44.000000000 +0300
@@ -421,7 +421,7 @@
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
 
 	if (!pskb_may_pull(skb, sizeof(struct xid_frame))) {
-		IRDA_ERROR("%s: frame to short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
 		return;
 	}
 
@@ -492,7 +492,7 @@
 	char *text;
 
 	if (!pskb_may_pull(skb, sizeof(struct xid_frame))) {
-		IRDA_ERROR("%s: frame to short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
 		return;
 	}
 
@@ -536,7 +536,7 @@
 		/* Check if things are sane at this point... */
 		if((discovery_info == NULL) ||
 		   !pskb_may_pull(skb, 3)) {
-			IRDA_ERROR("%s: discovery frame to short!\n",
+			IRDA_ERROR("%s: discovery frame too short!\n",
 				   __FUNCTION__);
 			return;
 		}
@@ -1181,7 +1181,7 @@
 	IRDA_ASSERT(info != NULL, return;);
 
 	if (!pskb_may_pull(skb, 4)) {
-		IRDA_ERROR("%s: frame to short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
 		return;
 	}
 
@@ -1270,7 +1270,7 @@
 	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
 
 	if (!pskb_may_pull(skb, sizeof(*frame))) {
-		IRDA_ERROR("%s: frame to short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
 		return;
 	}
 	frame = (struct test_frame *) skb->data;
@@ -1278,7 +1278,7 @@
 	/* Broadcast frames must carry saddr and daddr fields */
 	if (info->caddr == CBROADCAST) {
 		if (skb->len < sizeof(struct test_frame)) {
-			IRDA_DEBUG(0, "%s() test frame to short!\n",
+			IRDA_DEBUG(0, "%s() test frame too short!\n",
 				   __FUNCTION__);
 			return;
 		}
@@ -1344,7 +1344,7 @@
 
 	/* Check if frame is large enough for parsing */
 	if (!pskb_may_pull(skb, 2)) {
-		IRDA_ERROR("%s: frame to short!\n", __FUNCTION__);
+		IRDA_ERROR("%s: frame too short!\n", __FUNCTION__);
 		dev_kfree_skb(skb);
 		return -1;
 	}
Index: net-2.6.22-quilt/net/irda/irttp.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/irttp.c	2007-04-18 01:57:48.000000000 +0300
+++ net-2.6.22-quilt/net/irda/irttp.c	2007-04-18 02:16:44.000000000 +0300
@@ -551,7 +551,7 @@
 	}
 
 	if (skb->len > self->max_seg_size) {
-		IRDA_DEBUG(1, "%s(), UData is to large for IrLAP!\n",
+		IRDA_DEBUG(1, "%s(), UData is too large for IrLAP!\n",
 			   __FUNCTION__);
 		goto err;
 	}
@@ -598,7 +598,7 @@
 	 *  inside an IrLAP frame
 	 */
 	if ((self->tx_max_sdu_size == 0) && (skb->len > self->max_seg_size)) {
-		IRDA_ERROR("%s: SAR disabled, and data is to large for IrLAP!\n",
+		IRDA_ERROR("%s: SAR disabled, and data is too large for IrLAP!\n",
 			   __FUNCTION__);
 		ret = -EMSGSIZE;
 		goto err;
Index: net-2.6.22-quilt/net/irda/parameters.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/parameters.c	2007-04-18 01:57:48.000000000 +0300
+++ net-2.6.22-quilt/net/irda/parameters.c	2007-04-18 02:16:44.000000000 +0300
@@ -160,7 +160,7 @@
 	}
 	/* Check if buffer is long enough for insertion */
 	if (len < (2+p.pl)) {
-		IRDA_WARNING("%s: buffer to short for insertion!\n",
+		IRDA_WARNING("%s: buffer too short for insertion!\n",
 			     __FUNCTION__);
 		return -1;
 	}
@@ -216,7 +216,7 @@
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
-		IRDA_WARNING("%s: buffer to short for parsing! "
+		IRDA_WARNING("%s: buffer too short for parsing! "
 			     "Need %d bytes, but len is only %d\n",
 			     __FUNCTION__, p.pl, len);
 		return -1;
@@ -304,7 +304,7 @@
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
-		IRDA_WARNING("%s: buffer to short for parsing! "
+		IRDA_WARNING("%s: buffer too short for parsing! "
 			     "Need %d bytes, but len is only %d\n",
 			     __FUNCTION__, p.pl, len);
 		return -1;
@@ -343,7 +343,7 @@
 
 	/* Check if buffer is long enough for parsing */
 	if (len < (2+p.pl)) {
-		IRDA_WARNING("%s: buffer to short for parsing! "
+		IRDA_WARNING("%s: buffer too short for parsing! "
 			     "Need %d bytes, but len is only %d\n",
 			     __FUNCTION__, p.pl, len);
 		return -1;

--


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/

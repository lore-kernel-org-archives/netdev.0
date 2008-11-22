From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 5/5] enic: misc cleanup items:
Date: Fri, 21 Nov 2008 16:34:18 -0800
Message-ID: <20081122003418.15540.83506.stgit@palito_client100.nuovasystems.com>
References: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:33339 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754873AbYKVAlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:41:52 -0500
In-Reply-To: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: misc cleanup items:

Clarrify reading PBA has no side-effect (clearing).
Add missing GPL license text.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/vnic_intr.h     |    2 +-
 drivers/net/enic/vnic_resource.h |    2 +-
 drivers/net/enic/vnic_rss.h      |   13 +++++++++++++
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/enic/vnic_intr.h b/drivers/net/enic/vnic_intr.h
index ccc4081..ce633a5 100644
--- a/drivers/net/enic/vnic_intr.h
+++ b/drivers/net/enic/vnic_intr.h
@@ -78,7 +78,7 @@ static inline void vnic_intr_return_credits(struct vnic_intr *intr,
 
 static inline u32 vnic_intr_legacy_pba(u32 __iomem *legacy_pba)
 {
-	/* get and ack interrupt in one read (clear-and-ack-on-read) */
+	/* read PBA without clearing */
 	return ioread32(legacy_pba);
 }
 
diff --git a/drivers/net/enic/vnic_resource.h b/drivers/net/enic/vnic_resource.h
index 144d281..b61c22a 100644
--- a/drivers/net/enic/vnic_resource.h
+++ b/drivers/net/enic/vnic_resource.h
@@ -38,7 +38,7 @@ enum vnic_res_type {
 	RES_TYPE_INTR_CTRL,		/* Interrupt ctrl table */
 	RES_TYPE_INTR_TABLE,		/* MSI/MSI-X Interrupt table */
 	RES_TYPE_INTR_PBA,		/* MSI/MSI-X PBA table */
-	RES_TYPE_INTR_PBA_LEGACY,	/* Legacy intr status, r2c */
+	RES_TYPE_INTR_PBA_LEGACY,	/* Legacy intr status */
 	RES_TYPE_RSVD6,
 	RES_TYPE_RSVD7,
 	RES_TYPE_DEVCMD,		/* Device command region */
diff --git a/drivers/net/enic/vnic_rss.h b/drivers/net/enic/vnic_rss.h
index e325d65..5fbb3c9 100644
--- a/drivers/net/enic/vnic_rss.h
+++ b/drivers/net/enic/vnic_rss.h
@@ -1,6 +1,19 @@
 /*
  * Copyright 2008 Cisco Systems, Inc.  All rights reserved.
  * Copyright 2007 Nuova Systems, Inc.  All rights reserved.
+ *
+ * This program is free software; you may redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
  */
 
 #ifndef _VNIC_RSS_H_


From: Kyle McMartin <kyle@mcmartin.ca>
Subject: [PATCH] mlx4: needs vmalloc.h for vmap()
Date: Mon, 11 Feb 2008 17:11:15 -0500
Message-ID: <20080211221115.GH4516@phobos.i.cabal.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rolandd@cisco.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 206-248-169-182.dsl.ncf.ca ([206.248.169.182]:28514 "EHLO
	phobos.cabal.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbYBKWWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 17:22:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 313abe55a87bc10e55d00f337d609e17ad5f8c9a added a vmap usage to
mlx4. Unfortunately on some platforms (ppc64) <linux/vmalloc.h> is not
implicitly included. Fix that.

Signed-off-by: Kyle McMartin <kmcmartin@redhat.com>

---
diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/mlx4/alloc.c
index 521dc03..75ef9d0 100644
--- a/drivers/net/mlx4/alloc.c
+++ b/drivers/net/mlx4/alloc.c
@@ -34,6 +34,7 @@
 #include <linux/slab.h>
 #include <linux/bitmap.h>
 #include <linux/dma-mapping.h>
+#include <linux/vmalloc.h>
 
 #include "mlx4.h"
 

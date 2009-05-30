From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [SCSI] cxgb3i: Include net/dst.h for struct dst_cache
Date: Sat, 30 May 2009 13:40:04 +1000
Message-ID: <20090530034004.GA20516@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Mike Christie <michaelc@cs.wisc.edu>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-scsi@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53505 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754160AbZE3DkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 23:40:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

[SCSI] cxgb3i: Include net/dst.h for struct dst_cache

This driver needs dst_cache->dev so it should include net/dst.h
to ensure that it builds.  While net/tcp.h probably includes it
already, we shouldn't rely on that since there is no guarantee
that this won't change in future.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/scsi/cxgb3i/cxgb3i_iscsi.c b/drivers/scsi/cxgb3i/cxgb3i_iscsi.c
index 9212400..8b49731 100644
--- a/drivers/scsi/cxgb3i/cxgb3i_iscsi.c
+++ b/drivers/scsi/cxgb3i/cxgb3i_iscsi.c
@@ -13,6 +13,7 @@
 
 #include <linux/inet.h>
 #include <linux/crypto.h>
+#include <net/dst.h>
 #include <net/tcp.h>
 #include <scsi/scsi_cmnd.h>
 #include <scsi/scsi_device.h>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

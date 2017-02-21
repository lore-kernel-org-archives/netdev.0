From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH 1/9] fsl/fman: parse result data is big endian
Date: Tue, 21 Feb 2017 13:52:46 +0200
Message-ID: <1487677974-13678-2-git-send-email-madalin.bucur@nxp.com>
References: <1487677974-13678-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <camelia.groza@nxp.com>, <linuxppc-dev@lists.ozlabs.org>,
        Madalin Bucur <madalin.bucur@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0044.outbound.protection.outlook.com ([104.47.41.44]:54373
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752118AbdBULxT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Feb 2017 06:53:19 -0500
In-Reply-To: <1487677974-13678-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/fman/fman.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman.h b/drivers/net/ethernet/freescale/fman/fman.h
index 57aae8d..f53e147 100644
--- a/drivers/net/ethernet/freescale/fman/fman.h
+++ b/drivers/net/ethernet/freescale/fman/fman.h
@@ -134,14 +134,14 @@ enum fman_exceptions {
 struct fman_prs_result {
 	u8 lpid;		/* Logical port id */
 	u8 shimr;		/* Shim header result  */
-	u16 l2r;		/* Layer 2 result */
-	u16 l3r;		/* Layer 3 result */
+	__be16 l2r;		/* Layer 2 result */
+	__be16 l3r;		/* Layer 3 result */
 	u8 l4r;		/* Layer 4 result */
 	u8 cplan;		/* Classification plan id */
-	u16 nxthdr;		/* Next Header  */
-	u16 cksum;		/* Running-sum */
+	__be16 nxthdr;		/* Next Header  */
+	__be16 cksum;		/* Running-sum */
 	/* Flags&fragment-offset field of the last IP-header */
-	u16 flags_frag_off;
+	__be16 flags_frag_off;
 	/* Routing type field of a IPV6 routing extension header */
 	u8 route_type;
 	/* Routing Extension Header Present; last bit is IP valid */
-- 
2.1.0

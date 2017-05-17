From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH net-next 6/8] fsl/qe: add bit description for SYNL register for GUMR
Date: Wed, 17 May 2017 17:24:37 +0200
Message-ID: <20170517152439.8817-6-holger.brunck@keymile.com>
References: <20170517152439.8817-1-holger.brunck@keymile.com>
Cc: Holger Brunck <holger.brunck@keymile.com>,
        Zhao Qiang <qiang.zhao@nxp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:47196 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdEQPbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 11:31:07 -0400
In-Reply-To: <20170517152439.8817-1-holger.brunck@keymile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the bitmask for the two bit SYNL register according to the QUICK
Engine Reference Manual.

Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
Cc: Zhao Qiang <qiang.zhao@nxp.com>
---
 include/soc/fsl/qe/qe.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/soc/fsl/qe/qe.h b/include/soc/fsl/qe/qe.h
index 0cd4c11479b1..226f915a68c2 100644
--- a/include/soc/fsl/qe/qe.h
+++ b/include/soc/fsl/qe/qe.h
@@ -668,6 +668,10 @@ struct ucc_slow_pram {
 #define UCC_FAST_GUMR_CTSS	0x00800000
 #define UCC_FAST_GUMR_TXSY	0x00020000
 #define UCC_FAST_GUMR_RSYN	0x00010000
+#define UCC_FAST_GUMR_SYNL_MASK	0x0000C000
+#define UCC_FAST_GUMR_SYNL_16	0x0000C000
+#define UCC_FAST_GUMR_SYNL_8	0x00008000
+#define UCC_FAST_GUMR_SYNL_AUTO	0x00004000
 #define UCC_FAST_GUMR_RTSM	0x00002000
 #define UCC_FAST_GUMR_REVD	0x00000400
 #define UCC_FAST_GUMR_ENR	0x00000020
-- 
2.12.0.rc1

From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4vf: Replace repetitive pci device ID's with right ones
Date: Mon, 27 Oct 2014 23:22:10 +0530
Message-ID: <1414432330-12130-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:38222
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752252AbaJ0Rqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 13:46:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replaced repetive Device ID's which got added in commit b961f9a48844ecf3
("cxgb4vf: Remove superfluous "idx" parameter of CH_DEVICE() macro")

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index bfa398d..0b42bdd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2929,14 +2929,14 @@ static const struct pci_device_id cxgb4vf_pci_tbl[] = {
 	CH_DEVICE(0x480d),	/* T480-cr */
 	CH_DEVICE(0x480e),	/* T440-lp-cr */
 	CH_DEVICE(0x4880),
-	CH_DEVICE(0x4880),
-	CH_DEVICE(0x4880),
-	CH_DEVICE(0x4880),
-	CH_DEVICE(0x4880),
-	CH_DEVICE(0x4880),
-	CH_DEVICE(0x4880),
-	CH_DEVICE(0x4880),
-	CH_DEVICE(0x4880),
+	CH_DEVICE(0x4881),
+	CH_DEVICE(0x4882),
+	CH_DEVICE(0x4883),
+	CH_DEVICE(0x4884),
+	CH_DEVICE(0x4885),
+	CH_DEVICE(0x4886),
+	CH_DEVICE(0x4887),
+	CH_DEVICE(0x4888),
 	CH_DEVICE(0x5801),	/* T520-cr */
 	CH_DEVICE(0x5802),	/* T522-cr */
 	CH_DEVICE(0x5803),	/* T540-cr */
-- 
1.7.1

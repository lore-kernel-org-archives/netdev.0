From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/5] cxgb4/cxgb4vf: Add device ID for new adapter and remove for dbg adapter
Date: Wed, 10 Sep 2014 17:44:31 +0530
Message-ID: <1410351271-26428-6-git-send-email-hariprasad@chelsio.com>
References: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:42782
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751344AbaIJMJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 08:09:11 -0400
In-Reply-To: <1410351271-26428-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    2 ++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    3 +--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d6a9a0b..f56b95a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -283,6 +283,7 @@ static const struct pci_device_id cxgb4_pci_tbl[] = {
 	CH_DEVICE(0x5083, 4),
 	CH_DEVICE(0x5084, 4),
 	CH_DEVICE(0x5085, 4),
+	CH_DEVICE(0x5086, 4),
 	CH_DEVICE(0x5401, 4),
 	CH_DEVICE(0x5402, 4),
 	CH_DEVICE(0x5403, 4),
@@ -310,6 +311,7 @@ static const struct pci_device_id cxgb4_pci_tbl[] = {
 	CH_DEVICE(0x5483, 4),
 	CH_DEVICE(0x5484, 4),
 	CH_DEVICE(0x5485, 4),
+	CH_DEVICE(0x5486, 4),
 	{ 0, }
 };
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 2102a4c..8253403 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2912,7 +2912,6 @@ static void cxgb4vf_pci_shutdown(struct pci_dev *pdev)
 
 static const struct pci_device_id cxgb4vf_pci_tbl[] = {
 	CH_DEVICE(0xb000, 0),	/* PE10K FPGA */
-	CH_DEVICE(0x4800, 0),	/* T440-dbg */
 	CH_DEVICE(0x4801, 0),	/* T420-cr */
 	CH_DEVICE(0x4802, 0),	/* T422-cr */
 	CH_DEVICE(0x4803, 0),	/* T440-cr */
@@ -2934,7 +2933,6 @@ static const struct pci_device_id cxgb4vf_pci_tbl[] = {
 	CH_DEVICE(0x4880, 6),
 	CH_DEVICE(0x4880, 7),
 	CH_DEVICE(0x4880, 8),
-	CH_DEVICE(0x5800, 0),	/* T580-dbg */
 	CH_DEVICE(0x5801, 0),	/* T520-cr */
 	CH_DEVICE(0x5802, 0),	/* T522-cr */
 	CH_DEVICE(0x5803, 0),	/* T540-cr */
@@ -2962,6 +2960,7 @@ static const struct pci_device_id cxgb4vf_pci_tbl[] = {
 	CH_DEVICE(0x5883, 0),
 	CH_DEVICE(0x5884, 0),
 	CH_DEVICE(0x5885, 0),
+	CH_DEVICE(0x5886, 0),
 	{ 0, }
 };
 
-- 
1.7.1

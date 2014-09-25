From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4/cxgb4vf: Add Devicde ID for two more adapter
Date: Fri, 26 Sep 2014 00:23:54 +0530
Message-ID: <1411671235-6527-4-git-send-email-hariprasad@chelsio.com>
References: <1411671235-6527-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:50765
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751514AbaIYSst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 14:48:49 -0400
In-Reply-To: <1411671235-6527-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |    4 ++++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    2 ++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index eeec495..b9596a3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -284,6 +284,8 @@ static const struct pci_device_id cxgb4_pci_tbl[] = {
 	CH_DEVICE(0x5084, 4),
 	CH_DEVICE(0x5085, 4),
 	CH_DEVICE(0x5086, 4),
+	CH_DEVICE(0x5087, 4),
+	CH_DEVICE(0x5088, 4),
 	CH_DEVICE(0x5401, 4),
 	CH_DEVICE(0x5402, 4),
 	CH_DEVICE(0x5403, 4),
@@ -312,6 +314,8 @@ static const struct pci_device_id cxgb4_pci_tbl[] = {
 	CH_DEVICE(0x5484, 4),
 	CH_DEVICE(0x5485, 4),
 	CH_DEVICE(0x5486, 4),
+	CH_DEVICE(0x5487, 4),
+	CH_DEVICE(0x5488, 4),
 	{ 0, }
 };
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 656c36e..8498a64 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2961,6 +2961,8 @@ static const struct pci_device_id cxgb4vf_pci_tbl[] = {
 	CH_DEVICE(0x5884),
 	CH_DEVICE(0x5885),
 	CH_DEVICE(0x5886),
+	CH_DEVICE(0x5887),
+	CH_DEVICE(0x5888),
 	{ 0, }
 };
 
-- 
1.7.1

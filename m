From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 05/10] net: thunderx: delete unused variables
Date: Tue, 2 Jun 2015 11:00:22 -0700
Message-ID: <1433268028-23992-6-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0069.outbound.protection.outlook.com ([207.46.100.69]:64780
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759923AbbFBSBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 14:01:15 -0400
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They were left from development stage

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index a58924c..83476f0 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -38,7 +38,7 @@ struct lmac {
 	bool			is_sgmii;
 	struct delayed_work	dwork;
 	struct workqueue_struct *check_link;
-} lmac;
+};
 
 struct bgx {
 	u8			bgx_id;
@@ -50,7 +50,7 @@ struct bgx {
 	int			use_training;
 	void __iomem		*reg_base;
 	struct pci_dev		*pdev;
-} bgx;
+};
 
 struct bgx *bgx_vnic[MAX_BGX_THUNDER];
 static int lmac_count; /* Total no of LMACs in system */
-- 
2.4.1

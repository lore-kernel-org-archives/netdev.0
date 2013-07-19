From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 7/9] qlcnic: Fix dump template version mask
Date: Fri, 19 Jul 2013 16:56:32 -0400
Message-ID: <1374267394-27697-8-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe002.messaging.microsoft.com ([65.55.88.12]:26502 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751791Ab3GSVYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:04 -0400
In-Reply-To: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Driver was using wrong mask for template version.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index ab8a674..79e54ef 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1084,7 +1084,7 @@ flash_temp:
 	tmpl_hdr = ahw->fw_dump.tmpl_hdr;
 	tmpl_hdr->drv_cap_mask = QLCNIC_DUMP_MASK_DEF;
 
-	if ((tmpl_hdr->version & 0xffffff) >= 0x20001)
+	if ((tmpl_hdr->version & 0xfffff) >= 0x20001)
 		ahw->fw_dump.use_pex_dma = true;
 	else
 		ahw->fw_dump.use_pex_dma = false;
-- 
1.7.1

From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 7/8] bna: Firmware Image Naming Change
Date: Wed, 5 Dec 2012 15:01:09 -0800
Message-ID: <1354748470-26293-8-git-send-email-rmody@brocade.com>
References: <1354748470-26293-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:46622 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751029Ab2LEXW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 18:22:59 -0500
In-Reply-To: <1354748470-26293-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
        Modified the firmware naming convention to contain the firmware image
version (3.1.0.0). The new convention is <firmware-image>-<firmware-version>.bin
The change will enforce loading only compatible firmware with this driver and
also avoid over-writing the old firmware image in-order to load new version
driver as the firmware names used to be the same.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/cna.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index 32e8f17..14ca931 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -37,8 +37,8 @@
 
 extern char bfa_version[];
 
-#define	CNA_FW_FILE_CT	"ctfw.bin"
-#define	CNA_FW_FILE_CT2	"ct2fw.bin"
+#define CNA_FW_FILE_CT	"ctfw-3.1.0.0.bin"
+#define CNA_FW_FILE_CT2	"ct2fw-3.1.0.0.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
 #pragma pack(1)
-- 
1.7.1

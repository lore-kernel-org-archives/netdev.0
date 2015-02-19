From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: [net-next v2 2/2] bna: Update the Driver and Firmware Version
Date: Thu, 19 Feb 2015 16:02:32 -0500
Message-ID: <1424379752-4246-3-git-send-email-rasesh.mody@qlogic.com>
References: <1424379752-4246-1-git-send-email-rasesh.mody@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NetDev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54569 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753160AbbBSVmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 16:42:07 -0500
In-Reply-To: <1424379752-4246-1-git-send-email-rasesh.mody@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the BNA driver version to 3.2.25.1 and the firmware version
to 3.2.5.1

Signed-off-by: Rasesh Mody <rasesh.mody@qlogic.com>
---
 drivers/net/ethernet/brocade/bna/bnad.h | 2 +-
 drivers/net/ethernet/brocade/bna/cna.h  | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index e6c285c..7ead6c2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -72,7 +72,7 @@ struct bnad_rx_ctrl {
 #define BNAD_NAME			"bna"
 #define BNAD_NAME_LEN			64
 
-#define BNAD_VERSION			"3.2.23.0"
+#define BNAD_VERSION			"3.2.25.1"
 
 #define BNAD_MAILBOX_MSIX_INDEX		0
 #define BNAD_MAILBOX_MSIX_VECTORS	1
diff --git a/drivers/net/ethernet/brocade/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
index 3be5d98..28e7d0f 100644
--- a/drivers/net/ethernet/brocade/bna/cna.h
+++ b/drivers/net/ethernet/brocade/bna/cna.h
@@ -38,8 +38,8 @@
 
 extern char bfa_version[];
 
-#define CNA_FW_FILE_CT	"ctfw-3.2.3.0.bin"
-#define CNA_FW_FILE_CT2	"ct2fw-3.2.3.0.bin"
+#define CNA_FW_FILE_CT	"ctfw-3.2.5.1.bin"
+#define CNA_FW_FILE_CT2	"ct2fw-3.2.5.1.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
 #pragma pack(1)
-- 
1.8.2.3

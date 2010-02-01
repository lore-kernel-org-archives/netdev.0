From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 2/7] qlcnic: add ethernet identifier in board info
Date: Mon,  1 Feb 2010 07:24:55 -0800
Message-ID: <1265037900-20403-3-git-send-email-amit.salecha@qlogic.com>
References: <1265037900-20403-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com,
	Rajesh K Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:11615 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755042Ab0BAPZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 10:25:03 -0500
In-Reply-To: <1265037900-20403-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added missing identifier that distinguishes between
FCOE/ISCSI/ETHERNET functions.

Signed-off-by: Rajesh K Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index abec468..9662a37 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1068,7 +1068,7 @@ int qlcnic_reset_context(struct qlcnic_adapter *);
  * QLOGIC Board information
  */
 
-#define QLCNIC_MAX_BOARD_NAME_LEN 64
+#define QLCNIC_MAX_BOARD_NAME_LEN 100
 struct qlcnic_brdinfo {
 	unsigned short  vendor;
 	unsigned short  device;
@@ -1078,8 +1078,12 @@ struct qlcnic_brdinfo {
 };
 
 static const struct qlcnic_brdinfo qlcnic_boards[] = {
-	{0x1077, 0x8020, 0x1077, 0x203, "8200 Series Single Port 10GbE CNA"},
-	{0x1077, 0x8020, 0x1077, 0x207, "8200 Series Dual Port 10GbE CNA"},
+	{0x1077, 0x8020, 0x1077, 0x203,
+		"8200 Series Single Port 10GbE Converged Network Adapter \
+		(TCP/IP Networking)"},
+	{0x1077, 0x8020, 0x1077, 0x207,
+		"8200 Series Dual Port 10GbE Converged Network Adapter \
+		(TCP/IP Networking)"},
 	{0x1077, 0x8020, 0x1077, 0x20b,
 		"3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
 	{0x1077, 0x8020, 0x1077, 0x20c,
-- 
1.6.0.2


From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 3/9] qlcnic: Add identifying string for 83xx adapter
Date: Sat, 13 Apr 2013 13:28:28 -0400
Message-ID: <1365874114-6759-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:42936 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752764Ab3DMRwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:52:31 -0400
In-Reply-To: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

Added description for Hilda 8300 Series of Adapters.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   31 ++++++++++++++++++++++
 1 files changed, 31 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0d00b2b..424a5e0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -156,6 +156,37 @@ static const u32 qlcnic_reg_tbl[] = {
 };
 
 static const struct qlcnic_board_info qlcnic_boards[] = {
+	{0x1077, 0x8030, 0x1077, 0x24e,
+	 "8300 Series Dual Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x243,
+	 "8300 Series Single Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x24a,
+	 "8300 Series Dual Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x246,
+	 "8300 Series Dual Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x252,
+	 "8300 Series Dual Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x26e,
+	 "8300 Series Dual Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x260,
+	 "8300 Series Dual Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x266,
+	 "8300 Series Single Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x269,
+	 "8300 Series Dual Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x1077, 0x271,
+	 "8300 Series Dual Port 10GbE Converged Network Adapter "
+	 "(TCP/IP Networking)"},
+	{0x1077, 0x8030, 0x0, 0x0, "8300 Series 1/10GbE Controller"},
 	{0x1077, 0x8020, 0x1077, 0x203,
 	 "8200 Series Single Port 10GbE Converged Network Adapter"
 	 "(TCP/IP Networking)"},
-- 
1.5.6

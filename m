From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 6/7] qlcnic: Add identifying string for 83xx adapter
Date: Wed, 24 Apr 2013 18:42:44 -0400
Message-ID: <1366843365-2787-7-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe002.messaging.microsoft.com ([216.32.181.182]:48138
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932204Ab3DXXHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:07:17 -0400
In-Reply-To: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Added identifying strings for 8300 Series of adapters.
o updated PCI_VENDOR_ID_QLOGIC and PCI_DEVICE_ID_824X for 8200
  Series adapter.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  125 ++++++++++++++++++----
 1 files changed, 106 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1310b7b..264d5a4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -156,25 +156,112 @@ static const u32 qlcnic_reg_tbl[] = {
 };
 
 static const struct qlcnic_board_info qlcnic_boards[] = {
-	{0x1077, 0x8020, 0x1077, 0x203,
-	 "8200 Series Single Port 10GbE Converged Network Adapter"
-	 "(TCP/IP Networking)"},
-	{0x1077, 0x8020, 0x1077, 0x207,
-	 "8200 Series Dual Port 10GbE Converged Network Adapter"
-	 "(TCP/IP Networking)"},
-	{0x1077, 0x8020, 0x1077, 0x20b,
-	 "3200 Series Dual Port 10Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x20c,
-	 "3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x20f,
-	 "3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
-	{0x1077, 0x8020, 0x103c, 0x3733,
-	 "NC523SFP 10Gb 2-port Server Adapter"},
-	{0x1077, 0x8020, 0x103c, 0x3346,
-	 "CN1000Q Dual Port Converged Network Adapter"},
-	{0x1077, 0x8020, 0x1077, 0x210,
-	 "QME8242-k 10GbE Dual Port Mezzanine Card"},
-	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x24e,
+	  "8300 Series Dual Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x243,
+	  "8300 Series Single Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x24a,
+	  "8300 Series Dual Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x246,
+	  "8300 Series Dual Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x252,
+	  "8300 Series Dual Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x26e,
+	  "8300 Series Dual Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x260,
+	  "8300 Series Dual Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x266,
+	  "8300 Series Single Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x269,
+	  "8300 Series Dual Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x271,
+	  "8300 Series Dual Port 10GbE Converged Network Adapter "
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE834X,
+	  0x0, 0x0, "8300 Series 1/10GbE Controller" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x203,
+	  "8200 Series Single Port 10GbE Converged Network Adapter"
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x207,
+	  "8200 Series Dual Port 10GbE Converged Network Adapter"
+	  "(TCP/IP Networking)" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x20b,
+	  "3200 Series Dual Port 10Gb Intelligent Ethernet Adapter" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x20c,
+	  "3200 Series Quad Port 1Gb Intelligent Ethernet Adapter" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x20f,
+	  "3200 Series Single Port 10Gb Intelligent Ethernet Adapter" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  0x103c, 0x3733,
+	  "NC523SFP 10Gb 2-port Server Adapter" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  0x103c, 0x3346,
+	  "CN1000Q Dual Port Converged Network Adapter" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  PCI_VENDOR_ID_QLOGIC,
+	  0x210,
+	  "QME8242-k 10GbE Dual Port Mezzanine Card" },
+	{ PCI_VENDOR_ID_QLOGIC,
+	  PCI_DEVICE_ID_QLOGIC_QLE824X,
+	  0x0, 0x0, "cLOM8214 1/10GbE Controller" },
 };
 
 #define NUM_SUPPORTED_BOARDS ARRAY_SIZE(qlcnic_boards)
-- 
1.7.6.rc1.1.g2c162b

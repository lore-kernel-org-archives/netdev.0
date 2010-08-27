From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 3/3] qlcnic: PCI ID addition
Date: Thu, 26 Aug 2010 17:03:05 -0700
Message-ID: <alpine.OSX.2.00.1008261655470.9385@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:23124 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316Ab0H0ADG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 20:03:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Added PCI ID to board info.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index f9d86fa..3880c0e 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1325,6 +1325,8 @@ static const struct qlcnic_brdinfo qlcnic_boards[] = {
 		"3200 Series Quad Port 1Gb Intelligent Ethernet Adapter"},
 	{0x1077, 0x8020, 0x1077, 0x20f,
 		"3200 Series Single Port 10Gb Intelligent Ethernet Adapter"},
+	{0x1077, 0x8020, 0x103c, 0x3733,
+		"NC523SFP 10Gb 2-port Flex-10 Server Adapter"},
 	{0x1077, 0x8020, 0x0, 0x0, "cLOM8214 1/10GbE Controller"},
 };
 
-- 
1.6.0.2


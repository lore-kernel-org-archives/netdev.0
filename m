From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net v2 3/4] net: mvneta: fix error messages in mvneta_port_down function
Date: Sat, 12 Mar 2016 18:44:19 +0100
Message-ID: <1457804660-8463-4-git-send-email-gregory.clement@free-electrons.com>
References: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Dimitri Epshtein <dima@marvell.com>,
	Ofer Heifetz <oferh@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:54421 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751959AbcCLRoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 12:44:37 -0500
In-Reply-To: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitri Epshtein <dima@marvell.com>

This commit corrects error printing when shutting down the port.

[gregory.clement@free-electrons.com: split initial commit in two
individual changes]
Signed-off-by: Dmitri Epshtein <dima@marvell.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 2ee05cebea75..58ad36876e8b 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -873,7 +873,7 @@ static void mvneta_port_down(struct mvneta_port *pp)
 	do {
 		if (count++ >= MVNETA_RX_DISABLE_TIMEOUT_MSEC) {
 			netdev_warn(pp->dev,
-				    "TIMEOUT for RX stopped ! rx_queue_cmd: 0x08%x\n",
+				    "TIMEOUT for RX stopped ! rx_queue_cmd: 0x%08x\n",
 				    val);
 			break;
 		}
@@ -912,7 +912,7 @@ static void mvneta_port_down(struct mvneta_port *pp)
 	do {
 		if (count++ >= MVNETA_TX_FIFO_EMPTY_TIMEOUT) {
 			netdev_warn(pp->dev,
-				    "TX FIFO empty timeout status=0x08%x\n",
+				    "TX FIFO empty timeout status=0x%08x\n",
 				    val);
 			break;
 		}
-- 
2.5.0

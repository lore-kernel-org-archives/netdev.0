From: Mirko Lindner <mlindner@marvell.com>
Subject: [PATCH net-next] Added FS A8NE-FM to the list of 32bit DMA boards
Date: Tue, 17 Jun 2014 12:53:39 +0200
Message-ID: <53A01E33.7000905@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:23825 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753304AbaFQKxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 06:53:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added FUJITSU SIEMENS A8NE-FM to the list of 32bit DMA boards

>From Tomi O.:
After I added an entry to this MB into the skge.c
driver in order to enable the mentioned 64bit dma disable quirk,
the network data corruptions ended and everything is fine again.

Signed-off-by: Mirko Lindner <mlindner@marvell.com>
---
 drivers/net/ethernet/marvell/skge.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 7f81ae6..e912b68 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -4199,6 +4199,13 @@ static struct dmi_system_id skge_32bit_dma_boards[] = {
 			DMI_MATCH(DMI_BOARD_NAME, "P5NSLI")
 		},
 	},
+	{
+		.ident = "FUJITSU SIEMENS A8NE-FM",
+		.matches = {
+			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTek Computer INC."),
+			DMI_MATCH(DMI_BOARD_NAME, "A8NE-FM")
+		},
+	},
 	{}
 };
 
-- 
1.8.4.5

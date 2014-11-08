From: Alban Bedel <albeu@free.fr>
Subject: [PATCH 2/2] 8139too: Allow using the largest possible MTU
Date: Sat,  8 Nov 2014 12:48:36 +0100
Message-ID: <1415447316-12424-2-git-send-email-albeu@free.fr>
References: <1415447316-12424-1-git-send-email-albeu@free.fr>
Cc: netdev@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Benoit Taine <benoit.taine@lip6.fr>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alban Bedel <albeu@free.fr>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415447316-12424-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver allows MTU up to 1518 bytes which is not enought to run
batman-adv. Simply raise the maximum packet size up to the maximum
allowed by the transmit descriptor, 1792 bytes, giving a maximum MTU
of 1774 bytes.

Signed-off-by: Alban Bedel <albeu@free.fr>
---
 drivers/net/ethernet/realtek/8139too.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 8387de9..e157541 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -183,7 +183,7 @@ static int debug = -1;
 #define NUM_TX_DESC	4
 
 /* max supported ethernet frame size -- must be at least (dev->mtu+14+4).*/
-#define MAX_ETH_FRAME_SIZE	1536
+#define MAX_ETH_FRAME_SIZE	1792
 
 /* max supported payload size */
 #define MAX_ETH_DATA_SIZE	(MAX_ETH_FRAME_SIZE - ETH_HLEN - ETH_FCS_LEN)
-- 
2.0.0

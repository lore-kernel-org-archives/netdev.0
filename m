From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 2/2] net: eth: davinci_cpdma: Mark a local variable static
Date: Wed, 11 Dec 2013 15:51:21 -0800
Message-ID: <1386805882-25360-2-git-send-email-olof@lixom.net>
References: <1386805882-25360-1-git-send-email-olof@lixom.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, Olof Johansson <olof@lixom.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386805882-25360-1-git-send-email-olof@lixom.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only used locally. Found by sparse.

Signed-off-by: Olof Johansson <olof@lixom.net>
---
 drivers/net/ethernet/ti/davinci_cpdma.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index b041a87..364d0c7 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -971,7 +971,7 @@ struct cpdma_control_info {
 #define ACCESS_RW	(ACCESS_RO | ACCESS_WO)
 };
 
-struct cpdma_control_info controls[] = {
+static struct cpdma_control_info controls[] = {
 	[CPDMA_CMD_IDLE]	  = {CPDMA_DMACONTROL,	3,  1,      ACCESS_WO},
 	[CPDMA_COPY_ERROR_FRAMES] = {CPDMA_DMACONTROL,	4,  1,      ACCESS_RW},
 	[CPDMA_RX_OFF_LEN_UPDATE] = {CPDMA_DMACONTROL,	2,  1,      ACCESS_RW},
-- 
1.7.10.4

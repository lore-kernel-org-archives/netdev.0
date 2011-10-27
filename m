From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net v2 6/7] bnx2x: use FW 7.0.29.0
Date: Thu, 27 Oct 2011 17:13:53 +0200
Message-ID: <1319728434-25038-2-git-send-email-yanivr@broadcom.com>
References: <1319728434-25038-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1242 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab1J0NOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 09:14:06 -0400
In-Reply-To: <1319728434-25038-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

The FW includes the following fixes:
  1. (iSCSI) Arrival of un-solicited ASYNC message causes
     firmware to abort the connection with RST.
  2. (FCoE) There is a probability that truncated FCoE packet on
     RX path won't get detected which might lead to FW assert.
  3. (iSCSI) Arrival of target-initiated NOP-IN during intense
     ISCSI traffic might lead to FW assert.
  4. (iSCSI) Chip hangs when in case of retransmission not aligned
     to 4-bytes from the beginning of iSCSI PDU.
  5. (FCoE) Arrival of packets beyond task IO size can lead to crash.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index e44b858..fc754cb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -2550,7 +2550,7 @@ struct host_func_stats {
 
 #define BCM_5710_FW_MAJOR_VERSION			7
 #define BCM_5710_FW_MINOR_VERSION			0
-#define BCM_5710_FW_REVISION_VERSION		23
+#define BCM_5710_FW_REVISION_VERSION		29
 #define BCM_5710_FW_ENGINEERING_VERSION		0
 #define BCM_5710_FW_COMPILE_FLAGS			1
 
-- 
1.7.2.2

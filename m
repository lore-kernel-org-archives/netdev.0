From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6] bnx2x: fix inverted condition
Date: Tue, 24 May 2011 15:06:06 +0300
Message-ID: <1306238767.9193.1.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1279 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754096Ab1EXMGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 08:06:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index d5bd35b..2890443 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -2675,7 +2675,7 @@ alloc_mem_err:
 	 * Min size diferent for TPA and non-TPA queues
 	 */
 	if (ring_size < (fp->disable_tpa ?
-				MIN_RX_SIZE_TPA : MIN_RX_SIZE_NONTPA)) {
+				MIN_RX_SIZE_NONTPA : MIN_RX_SIZE_TPA)) {
 			/* release memory allocated for this queue */
 			bnx2x_free_fp_mem_at(bp, index);
 			return -ENOMEM;
-- 
1.7.2.2





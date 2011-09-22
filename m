From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 3/3] bnx2x: add missing break in bnx2x_dcbnl_get_cap
Date: Thu, 22 Sep 2011 15:33:33 +0300
Message-ID: <1316694813-25274-3-git-send-email-dmitry@broadcom.com>
References: <1316694813-25274-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Shmulik Ravid" <shmulikr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2897 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577Ab1IVMdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 08:33:35 -0400
In-Reply-To: <1316694813-25274-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ravid <shmulikr@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_dcb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index a1e004a..0b4acf6 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -2120,6 +2120,7 @@ static u8 bnx2x_dcbnl_get_cap(struct net_device *netdev, int capid, u8 *cap)
 			break;
 		case DCB_CAP_ATTR_DCBX:
 			*cap = BNX2X_DCBX_CAPS;
+			break;
 		default:
 			rval = -EINVAL;
 			break;
-- 
1.7.2.2

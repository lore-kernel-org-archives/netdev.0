From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/4] net: cpsw: fix misplaced break statements.
Date: Mon, 25 May 2015 11:02:13 +0200
Message-ID: <363ac37dc263015774b5038a605a7d25a05c3097.1432544195.git.richardcochran@gmail.com>
References: <cover.1432544195.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34738 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbbEYJCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 05:02:24 -0400
Received: by wicmc15 with SMTP id mc15so35193926wic.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 02:02:23 -0700 (PDT)
In-Reply-To: <cover.1432544195.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having the breaks too far to the left makes parsing the dense switch/case
block unnecessarily harder.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b536b4c..e9e3ab3 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1456,7 +1456,7 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 
 		if (priv->cpts->rx_enable)
 			ctrl |= CTRL_V2_RX_TS_BITS;
-	break;
+		break;
 	case CPSW_VERSION_3:
 	default:
 		ctrl &= ~CTRL_V3_ALL_TS_MASK;
@@ -1466,7 +1466,7 @@ static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 
 		if (priv->cpts->rx_enable)
 			ctrl |= CTRL_V3_RX_TS_BITS;
-	break;
+		break;
 	}
 
 	mtype = (30 << TS_SEQ_ID_OFFSET_SHIFT) | EVENT_MSG_BITS;
-- 
2.1.4

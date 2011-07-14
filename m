From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/6] cnic: Fix port_mode setting
Date: Wed, 13 Jul 2011 20:24:18 -0700
Message-ID: <1310613862-27497-2-git-send-email-mchan@broadcom.com>
References: <1310613862-27497-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4342 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab1GNEQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 00:16:48 -0400
In-Reply-To: <1310613862-27497-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CHIP_2_PORT_MODE was not set correctly.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/cnic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 23d6108..a881e42 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -4834,7 +4834,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 			cp->port_mode = CHIP_4_PORT_MODE;
 			cp->pfid = func >> 1;
 		} else {
-			cp->port_mode = CHIP_4_PORT_MODE;
+			cp->port_mode = CHIP_2_PORT_MODE;
 			cp->pfid = func & 0x6;
 		}
 	} else {
-- 
1.6.4.GIT



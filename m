From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-2.6 7/8] bnx2x: Reset 8073 phy during common init
Date: Mon, 1 Nov 2010 17:32:41 +0200
Message-ID: <1288625561.3533.19.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3722 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757426Ab0KAMOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 08:14:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resetting 8073 during common init is required on boards in which the 8073 reset pin is not asserted by default.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index d076b91..5809196 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -7024,6 +7024,7 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 	s8 port;
 	s8 port_of_path = 0;
 
+	bnx2x_ext_phy_hw_reset(bp, 0);
 	/* PART1 - Reset both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		u32 shmem_base, shmem2_base;
-- 
1.7.1





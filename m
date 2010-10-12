From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: Fixing a typo: added a missing RSS
 enablement
Date: Tue, 12 Oct 2010 21:02:21 +0200
Message-ID: <1286910141.16797.23.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3219 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758164Ab0JLTCf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 15:02:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 7a9556b..ead524b 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2486,6 +2486,7 @@ void bnx2x_pf_init(struct bnx2x *bp)
 	 * if (is_eth_multi(bp))
 	 *	flags |= FUNC_FLG_RSS;
 	 */
+	flags |= FUNC_FLG_RSS;
 
 	/* function setup */
 	if (flags & FUNC_FLG_RSS) {
-- 
1.7.1





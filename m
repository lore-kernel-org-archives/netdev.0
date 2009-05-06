From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH 3/3] bnx2x: do not return negative number of received
 packages
Date: Wed, 6 May 2009 11:22:12 +0200
Message-ID: <20090506112212.6a4600db@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35059 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754115AbZEFJ20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2009 05:28:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 5bd42db..588c361 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1539,7 +1539,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 						    len, cqe, comp_ring_cons);
 #ifdef BNX2X_STOP_ON_ERROR
 					if (bp->panic)
-						return -EINVAL;
+						return 0;
 #endif
 
 					bnx2x_update_sge_prod(fp,
-- 
1.5.5.6


From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] r8169: remove unused variable
Date: Thu, 18 Jun 2009 15:49:49 +0200
Message-ID: <1245332989-26685-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:53472 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755869AbZFRNtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 09:49:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

all references got removed by 865c652d6be9929927cabdc54b137b7541eb6612
(r8169: remove non-napi code).

Signed-off-by: Florian Westphal <fwestphal@astaro.com>
---
 drivers/net/r8169.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4e22462..4b53b58 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -51,9 +51,6 @@
 #define TX_BUFFS_AVAIL(tp) \
 	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
 
-/* Maximum events (Rx packets, etc.) to handle at each interrupt. */
-static const int max_interrupt_work = 20;
-
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC. */
 static const int multicast_filter_limit = 32;
-- 
1.6.0.6


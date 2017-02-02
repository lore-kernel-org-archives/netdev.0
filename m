From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 05/12] net: mvpp2: remove unused 'tx_skb' field of 'struct mvpp2_tx_queue'
Date: Thu,  2 Feb 2017 16:51:34 +0100
Message-ID: <1486050701-27899-6-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1486050701-27899-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Russell King <linux@arm.linux.org.uk>,
        Stefan Chulski <stefanc@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:54838 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752062AbdBBPyH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:54:07 -0500
In-Reply-To: <1486050701-27899-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit remove a field of 'struct mvpp2_tx_queue' that is not used
anywhere.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 30aaff8..907619c 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -823,9 +823,6 @@ struct mvpp2_tx_queue {
 	/* Per-CPU control of physical Tx queues */
 	struct mvpp2_txq_pcpu __percpu *pcpu;
 
-	/* Array of transmitted skb */
-	struct sk_buff **tx_skb;
-
 	u32 done_pkts_coal;
 
 	/* Virtual address of thex Tx DMA descriptors array */
-- 
2.7.4

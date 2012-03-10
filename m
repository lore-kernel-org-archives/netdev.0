From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 1/2] r8169: enable transmit time stamping.
Date: Sat, 10 Mar 2012 18:29:42 +0100
Message-ID: <7ef0f3118d1ff0925852b31397e3bb9684e5a9fd.1331400160.git.richardcochran@gmail.com>
References: <cover.1331400160.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45740 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab2CJR3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Mar 2012 12:29:54 -0500
Received: by wejx9 with SMTP id x9so1974668wej.19
        for <netdev@vger.kernel.org>; Sat, 10 Mar 2012 09:29:53 -0800 (PST)
In-Reply-To: <cover.1331400160.git.richardcochran@gmail.com>
In-Reply-To: <cover.1331400160.git.richardcochran@gmail.com>
References: <cover.1331400160.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has been tested on a machine with the Realtek
RTL8101E/RTL8102E PCI Express Fast Ethernet controller (rev 05).

Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c04df3d..4c6041c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5564,6 +5564,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	netdev_sent_queue(dev, skb->len);
 
+	skb_tx_timestamp(skb);
+
 	wmb();
 
 	/* Anti gcc 2.95.3 bugware (sic) */
-- 
1.7.2.5

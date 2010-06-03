From: Junchang Wang <junchangwang@gmail.com>
Subject: [Patch 2/2]r8169: remove redundant RTL_W32
Date: Thu, 3 Jun 2010 19:27:23 +0800
Message-ID: <20100603112721.GD24909@host-a-55.ustcsz.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f185.google.com ([209.85.222.185]:45612 "EHLO
	mail-pz0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748Ab0FCL1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 07:27:22 -0400
Received: by pzk15 with SMTP id 15so3005328pzk.15
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 04:27:21 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Writting "cmd" into "CounterAddrLow" twice is redundant.

Signed-off-by: Junchang Wang <junchangwang@gmail.com>
---
 drivers/net/r8169.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..e0a77a0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1207,7 +1207,6 @@ static void rtl8169_update_counters(struct net_device *dev)
 
 	RTL_W32(CounterAddrHigh, (u64)paddr >> 32);
 	cmd = (u64)paddr & DMA_BIT_MASK(32);
-	RTL_W32(CounterAddrLow, cmd);
 	RTL_W32(CounterAddrLow, cmd | CounterDump);
 
 	while (wait--) {
--
